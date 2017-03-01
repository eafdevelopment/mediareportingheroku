class ClientChannels::Adwords < ClientChannel

  # For testing in console:
  # ClientChannel.last.fetch_metrics('2017-02-10', '2017-02-17', '749546343', 'india_recruitment_sept_2017')

  def fetch_metrics(from_date, to_date, adwords_campaign_uid, ga_campaign_name, optional={})
    # Find and return metrics from Google AdWords
    adwords_client.config.set("authentication.client_customer_id", self.uid) # DMU Intl: "752-213-4824"
    report_utils = adwords_client.report_utils()
    # Here we only expect reports that fit into memory. For large reports
    # you may want to save them to files and serve separately.
    report_data = report_utils.download_report(report_definition(adwords_campaign_uid, from_date, to_date))
    puts "> report_data:  " + report_data.inspect
    parsed_data = xml_doc  = Nokogiri::XML(report_data)
    puts "> parsed_data" + parsed_data.inspect

    # fetch from GA metrics, if ga_campaign_name.present?

    # complete the calculated metrics (CTR, CPC, cost per goal conversion [later])

    # turn into arrays as rows, to return to Report ready for view or CSV
    adwords_metrics = {
      header_row: [],
      data_rows: [],
      summary_row: []
    }
    return adwords_metrics
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
        :enable_gzip => 'FALSE'
      },
      :library => {
        :log_level => 'INFO' # or DEBUG
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

  def report_definition(campaign_id, from_date, to_date)
    fields = AppConfig.adwords_headers.for_csv.map(&:first)
    fields.push('Date') # for segmenting the results by day
    return {
      :selector => {
        :fields => fields,
        :predicates => {
          :field => 'CampaignId',
          :operator => 'IN',
          :values => [campaign_id]
        },
        :date_range => {
          :min => from_date.gsub(/\D/, ''),
          :max => to_date.gsub(/\D/, '')
        }
      },
      :report_name => 'AdWords Campaign Performance Report',
      :report_type => 'CAMPAIGN_PERFORMANCE_REPORT',
      :download_format => 'XML',
      :date_range_type => 'CUSTOM_DATE'
    }
  end

end
