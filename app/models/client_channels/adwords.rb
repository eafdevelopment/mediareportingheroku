class ClientChannels::Adwords < ClientChannel

  def generate_report_all_campaigns(from_date, to_date)
    # Get all the campaigns for this account.
    adwords_client.config.set("authentication.client_customer_id", self.uid)
    adwords_client.skip_report_header = true
    adwords_client.skip_report_summary = true
    report_utils = adwords_client.report_utils()
    report_data = report_utils.download_report(report_definition_all_campaigns(from_date, to_date))
    combined_data_rows = []
    parsed_csv = CSV.parse(report_data, headers: true)
    # we need to make sure there aren't any CSV-ruining commas in the 'Labels' fields
    parsed_csv.each { |row| row["Labels"].gsub!(",", "|"); row }
    parsed_csv.each_with_index do |row, index|
      # each row is an AdWords campaign, so attempt to fetch Google Analytics data
      # for that campaign
      # if index <= 3 # just do a few rows for testing (less slow)
        ga_data = GoogleAnalytics.fetch_and_parse_metrics(row["Day"], row["Day"], self.client.google_analytics_view_id, row["Campaign"])
        print ">> AdWord & Analytics metrics for campaign: #{row["Campaign"]}  "
        if ga_data[:data_rows].first
          # got some GA data, so concat to the AdWords data row
          combined_data_rows.push( row.map{|k,v| v}.concat(ga_data[:data_rows].first) )
        else
          # no GA data returned, so nothing to concat here
          combined_data_rows.push( row.map{|k,v| v} )
        end
      # end
    end
    header_row = AppConfig.adwords_headers.for_csv.map(&:second).concat(AppConfig.google_analytics_headers.for_csv.map(&:second))
    combined_data_rows.unshift(header_row)
    rows_for_csv = combined_data_rows.map{|row| row.join(",")}.join("\n")
    return rows_for_csv
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

  def report_definition_all_campaigns(from_date, to_date)
    fields = AppConfig.adwords_headers.for_csv.map(&:first)
    fields.push('Date') # for segmenting the results by day
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

end
