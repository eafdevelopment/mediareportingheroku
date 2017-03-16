class ClientChannels::Adwords < ClientChannel

  def generate_report_all_campaigns(from_date, to_date)
    # Get all the campaigns for this account.
    adwords_client.config.set("authentication.client_customer_id", self.uid)
    adwords_client.skip_report_header = true
    adwords_client.skip_report_summary = true
    # adwords_client.include_zero_impressions = true
    report_utils = adwords_client.report_utils()
    report_main = report_utils.download_report(report_def_all_campaigns(from_date, to_date))
    parsed_report_main = CSV.parse(report_main, headers: true)
    # Get a separate report containing conversions data
    adwords_client.include_zero_impressions = false # (the conversions report is incompatible with this setting)
    report_conversions = report_utils.download_report(report_def_all_campaigns_conversions(from_date, to_date))
    puts "> report_conversions: " + report_conversions.inspect
    # puts "> " + CSV.parse(report_conversions, headers: true).to_a.inspect #.max_by{|row| row.length}
    conversions_data = parsed_conversions_report(report_conversions)
    conversion_headers = create_conversion_headers(conversions_data)
    puts ">"
    puts "> conversion_headers: " + conversion_headers.inspect
    combined_data_rows = []

    parsed_report_main.each do |row|
      conversion_data_fields = create_conversion_data_fields(row["Day"], row["Campaign ID"], conversion_headers, conversions_data)
      # ga_data = GoogleAnalytics.fetch_and_parse_metrics(row["Day"], row["Day"], self.client.google_analytics_view_id, row["Campaign"])
      ga_data = {data_rows: []}
      if ga_data[:data_rows].first
        # got some GA data, so concat to the AdWords data row as well as possible conversion fields
        # combined_data_rows.push( row.map{|k,v| v}.concat(ga_data[:data_rows].first) )
      else
        # no GA data returned, so only concat possible conversion fields
        combined_data_rows.push( row.map{|k,v| v} )
      end
    end
    header_row = AppConfig.adwords_headers.for_csv.map(&:second).concat(conversion_headers).concat(AppConfig.google_analytics_headers.for_csv.map(&:second))
    combined_data_rows.unshift(header_row)
    
    # combined_data_rows.map{ |row|
    #   puts "-----"
    #   puts "> combined_data_rows row: " + row.inspect
    # }


    # conversion_report_rows = []
    
    
    # parsed_report_main.each_with_index do |row, index|
    #   puts "-"*40
    #   puts "> main row: " + row.inspect
    #   # for each main report row, see whether there is a conversion data row to concat
    #   parsed_report_conversions.each do |conversions_row|
    #     # puts "> conversions_row: " + conversions_row.inspect
    #     if row["Campaign ID"] == conversions_row["Campaign ID"] && row["Day"] == conversions_row["Day"]
    #       # matching row found, so update this variable with the fields from this row
    #       puts ">> MATCHING CONVERSIONS_ROW FOUND"
    #       puts conversions_row.inspect
    #       # conversion_report_headers.push(AppConfig.adwords_headers.conversions.map(&:second).reject{|header| header == "Date" || header == "Campaign ID"})
    #       conversion_report_rows.push(conversions_row.map{|k,v| v})
    #     end
    #   end
    # end
    # if conversion_report_rows.empty?
    #   # no conversions were setup for this campaign, so we need the correct amount
    #   # of empty fields
    #   conversion_report_rows.push(CSV::Row.new(AppConfig.adwords_headers.conversions.map(&:first), AppConfig.adwords_headers.conversions.map{|k| " "}, header_row: false))
    # end
    # puts ">"
    # puts "> conversion_report_headers: " + conversion_report_headers.inspect
    # puts "> conversion_report_rows: " + conversion_report_rows.inspect
    # puts "> conversion_report_rows.max_by: " + conversion_report_rows.max_by(&:length).inspect

    # # for each row, also fetch any Google Analytics data for that campaign

    return "" #combined_data_rows.map{ |row| row.to_csv }.join("")
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

    return @adwords_client
  end

  def report_def_all_campaigns(from_date, to_date)
    fields = AppConfig.adwords_headers.for_csv.map(&:first)
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

  def report_def_all_campaigns_conversions(from_date, to_date)
    fields = AppConfig.adwords_headers.conversions.map(&:first)
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

  def parsed_conversions_report(conversions_report)
    parsed_report = []
    CSV.parse(conversions_report, headers: true).each do |row|
      parsed_report.push(row.to_h)
    end
    return parsed_report
  end

  def create_conversion_headers(conversions_data_hash)
    headers = []
    grouped_conversion_types = conversions_data_hash.group_by{|row| row["Conversion Tracker Id"]}
    grouped_conversion_types.each do |conversion_type_id, conversions|
      conversions.each do |conversion|
        conversion_type_name = conversion["Conversion name"]
        unless headers.include?(conversion_type_name + " (total)")
          headers.push(conversion_type_name + " (total conversions)")
          headers.push(conversion_type_name + " (conversion rate)")
        end
      end
    end
    return headers
  end

  def create_conversion_data_fields(date, campaign_id, conversions_headers, conversions_data)
    data_fields = []
    puts "-----------------------------"
    # puts "> date: " + date.inspect
    # puts "> campaign_id: " + campaign_id.inspect
    # puts "> conversions_data: " + conversions_data.inspect
    associated_conversions = conversions_data.select{|conversion| conversion["Day"] == date && conversion["Campaign ID"] == campaign_id}
    # are there any associated conversions to return? (use conversions_headers to organise fields correctly)
    puts "> associated_conversions: " + associated_conversions.inspect
    conversions_headers.each do |header|
      puts "> checking header: " + header.inspect
      if associated_conversions.any?
        # put either a value or a -
        associated_conversions.select{ |conv|
          puts ">> associated conversion: " + conv.inspect
          
        }
      else
        puts ">> (need to return '-')"
        data_fields.push("-")
      end
    end
    puts "> returning data_fields: " + data_fields.inspect
    return data_fields
  end

end
