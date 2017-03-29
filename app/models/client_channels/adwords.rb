class ClientChannels::Adwords < ClientChannel

  def generate_report_all_campaigns(from_date, to_date)
    begin
      # Get data for all the campaigns for this account
      report_main = get_and_parse_report_main(from_date, to_date)

      # Get a separate report containing quality score data
      report_quality_score = get_and_parse_report_quality_score(from_date, to_date)

      # Get a separate report containing all conversions data
      report_conversions = get_and_parse_report_conversions(from_date, to_date)
      # And an array of all possible conversion column headers
      conversion_col_headers = get_and_parse_conversion_headers
      
      # Ready to combine main report data, conversion report data & GA data
      header_row = AppConfig.adwords_headers.main_report.map(&:second).concat(["Quality Score (AdGroup Avg.)"]).concat(conversion_col_headers).concat(AppConfig.google_analytics_headers.for_csv.map(&:second))
      combined_data_rows = []
      report_main.each do |row|
        associated_quality_scores = report_quality_score.select{|quality_score| quality_score["Day"] == row["Day"] && quality_score["Campaign ID"] == row["Campaign ID"]}
        avg_quality_score = quality_score_avg_adgroup(associated_quality_scores)
        associated_conversions = report_conversions.select{|conversion| conversion["Day"] == row["Day"] && conversion["Campaign ID"] == row["Campaign ID"]}
        conversion_data_fields = create_conversion_data_fields(conversion_col_headers, associated_conversions)
        ga_data = GoogleAnalytics.fetch_and_parse_metrics(row["Day"], row["Day"], self.client.google_analytics_view_id, row["Campaign"])
        if ga_data[:data_rows].first # if GA data present, concat it
          row = row.map{|k,v| v}.push(avg_quality_score).concat(conversion_data_fields).concat(ga_data[:data_rows].first)
        else # if not, concat the correct number of "-"s
          row = row.map{|k,v| v}.push(avg_quality_score).concat(conversion_data_fields).concat(AppConfig.google_analytics_headers.for_csv.map{|header| "-"})
        end
        if row.length != header_row.length
          return { error: "Header row and first data row lengths do not match." }
        end
        combined_data_rows.push(row)
      end

      combined_data_rows.unshift(header_row)
      return { csv: combined_data_rows.map{ |row| row.to_csv }.join("") }

    rescue => e
      # if a problem occurs, log the exception to Rollbar and return a
      # message to ReportWorker to put in the dataset's status explanation
      Rollbar.log(e)
      return { error: (e.try(:message) || e.try(:response) || e.inspect) }
    end
  end

  private

  # Internal: Build and return a new Adwords API client. Ensures that the
  # client has a valid un-expired token.
  #
  # Subsequent calls to this method will return the same initialized client.
  def adwords_client
    if @adwords_client
      # Ensure token hasn't expired
      @adwords_client.authorize
      update authentication: @adwords_client.get_auth_handler.get_token

      return @adwords_client
    end
  
    authentication_hash = AppConfig.adwords.deep_dup
    authentication_hash[:oauth2_token].merge!(self.authentication)

    @adwords_client = AdwordsApi::Api.new({
      :authentication => authentication_hash,
      :service => {
        :environment => 'PRODUCTION'
      },
      :connection => {
        :enable_gzip => 'TRUE'
      },
      :library => {
        :log_level => 'INFO', # or DEBUG
      }
    })

    # Try and get a new access token if it's expired.
    token = @adwords_client.authorize

    # AdwordsApi does nothing if issued_at is nil (for example, if we've never
    # requested an access token before for this client channel), but for us
    # that means we definitely want to get a new one!
    @adwords_client.get_auth_handler.refresh_token! if !token[:issued_at]

    update authentication: @adwords_client.get_auth_handler.get_token
    
    adwords_client.config.set("authentication.client_customer_id", self.uid)
    adwords_client.skip_report_header = true
    adwords_client.skip_report_summary = true

    return @adwords_client
  end

  def get_and_parse_report_main(from_date, to_date)
    adwords_client.include_zero_impressions = true
    report_utils = adwords_client.report_utils()
    report_main = report_utils.download_report(report_def_main(from_date, to_date))
    parsed_report = CSV.parse(report_main, headers: true)
    parsed_report.each do |row|
      # Adwords API returns money in 'micro currency units' (£1 = 1,000,000)
      if row["Cost"] != "0"
        row["Cost"] = ((row["Cost"].to_f) / 1000000).round(2).to_s
      end
      if row["Avg. CPC"] != "0"
        row["Avg. CPC"] = ((row["Avg. CPC"].to_f) / 1000000).round(2).to_s
      end
      # The final report header for avg. session duration doesn't include
      # (seconds), so format to a more recognisable time value
      if row["Avg. session duration (seconds)"] != "0"
        row["Avg. session duration (seconds)"] = Time.at(row["Avg. session duration (seconds)"].to_i).utc.strftime("%H:%M:%S")
      end
    end
    return parsed_report
  end

  def get_and_parse_report_quality_score(from_date, to_date)
    adwords_client.include_zero_impressions = false
    report_utils = adwords_client.report_utils()
    report_quality_score = report_utils.download_report(report_def_criteria_performance(from_date, to_date))
    parsed_report = []
    CSV.parse(report_quality_score, headers: true).each do |row|
      parsed_report.push(row.to_h)
    end
    return parsed_report
  end

  def quality_score_avg_adgroup(quality_score_data)
    if quality_score_data.any?
      # calculate avg quality score for the active adgroups found
      return (quality_score_data.map{|data| data["Quality score"].to_i}.reduce(:+)) / quality_score_data.length
    else
      return "-"
    end
  end

  def get_and_parse_conversion_headers
    adwords_client.include_zero_impressions = false
    conversions_service = adwords_client.service(:ConversionTrackerService, :v201609)
    query = 'SELECT Id, Name, Status ORDER BY Name'
    offset, page = 0, {}
    page_size = 500
    col_headers = []
    begin
      page_query = query + ' LIMIT %d,%d' % [offset, page_size]
      page = conversions_service.query(page_query)
      if page[:entries]
        page[:entries].each do |conversion|
          col_headers.push("[" + conversion[:id].to_s + "] " + conversion[:name] + " (Conversions)")
          col_headers.push("[" + conversion[:id].to_s + "] " + conversion[:name] + " (Conv. rate)")
        end
        # Increment values to request the next page.
        offset += page_size
      end
    end while page[:total_num_entries] > offset
    return col_headers
  end

  def get_and_parse_report_conversions(from_date, to_date)
    adwords_client.include_zero_impressions = false
    report_utils = adwords_client.report_utils()
    report_conversion_data = report_utils.download_report(report_def_campaign_conversion_data(from_date, to_date))
    parsed_report = []
    CSV.parse(report_conversion_data, headers: true).each do |row|
      parsed_report.push(row.to_h)
    end
    return parsed_report
  end

  def report_def_main(from_date, to_date)
    fields = AppConfig.adwords_headers.main_report.map(&:first)
    return {
      :selector => {
        :date_range => {
          :min => from_date.gsub(/\D/, ''),
          :max => to_date.gsub(/\D/, '')
        },
        :fields => fields,
        :predicates => {
          :field => 'CampaignStatus',
          :operator => 'IN',
          :values => ['ENABLED', 'PAUSED']
        }
      },
      :date_range_type => 'CUSTOM_DATE',
      :download_format => 'CSV',
      :report_name => 'AdWords Campaign Performance Report',
      :report_type => 'CAMPAIGN_PERFORMANCE_REPORT'
    }
  end

  def report_def_campaign_conversion_data(from_date, to_date)
    fields = AppConfig.adwords_headers.conversion_data.map(&:first)
    return {
      :selector => {
        :date_range => {
          :min => from_date.gsub(/\D/, ''),
          :max => to_date.gsub(/\D/, '')
        },
        :fields => fields,
        :predicates => {
          :field => 'CampaignStatus',
          :operator => 'IN',
          :values => ['ENABLED', 'PAUSED']
        }
      },
      :date_range_type => 'CUSTOM_DATE',
      :download_format => 'CSV',
      :report_name => 'AdWords Campaign Performance Report',
      :report_type => 'CAMPAIGN_PERFORMANCE_REPORT'
    }
  end

  def report_def_criteria_performance(from_date, to_date)
    fields = AppConfig.adwords_headers.criteria_performance.map(&:first)
    return {
      :selector => {
        :date_range => {
          :min => from_date.gsub(/\D/, ''),
          :max => to_date.gsub(/\D/, '')
        },
        :fields => fields,
        :predicates => [
          {
            :field => 'CampaignStatus',
            :operator => 'IN',
            :values => ['ENABLED', 'PAUSED']
          },
          {
            :field => 'AdGroupStatus',
            :operator => 'IN',
            :values => ['ENABLED']
          }
        ]
      },
      :date_range_type => 'CUSTOM_DATE',
      :download_format => 'CSV',
      :report_name => 'AdWords Criteria Performance Report',
      :report_type => 'CRITERIA_PERFORMANCE_REPORT'
    }
  end

  def create_conversion_data_fields(conversions_headers, conversions_data)
    # every row in our final CSV report should contain either data or "-"s
    # for each possible conversion column
    data_fields = []
    conversions_headers.each do |header|
      conversion_tracker_id = header.split("]").first.gsub("[", "")
      matching_conversion = conversions_data.select{ |conv| conv["Conversion Tracker Id"] == conversion_tracker_id }.first
      if matching_conversion.present?
        if header.include?("(Conversions)")
          data_fields.push(matching_conversion["Conversions"])
        elsif header.include?("(Conv. rate)")
          data_fields.push(matching_conversion["Conv. rate"])
        else
          data_fields.push("-")
        end
      else
        data_fields.push("-")
      end
    end
    return data_fields
  end

end
