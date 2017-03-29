require 'twitter-ads'

class ClientChannels::Twitter < ClientChannel

  def generate_report_all_campaigns(from, to)
    client = twitter_credentials
    account = client.accounts(self.uid)
    headers = AppConfig.twitter_headers.for_csv.map(&:last).concat(AppConfig.google_analytics_headers.for_csv.map(&:last))
    from = format_date(from, account.timezone)
    to = format_date(to, account.timezone)
    dates_array = (from..to).to_a

    # Getting metrics from Twitter Ads Ruby SDK, fetching one
    # block of stats per date to bypass 7-day limits
    data_rows = []
    campaigns = get_campaigns(self.uid)
    campaign_ids = campaigns.map{|campaign| campaign[:id]}
    data_rows = []
    begin
      campaign_ids.each_slice(20) do |batched_campaign_ids|
        puts "> batched_campaign_ids: " + batched_campaign_ids.inspect
        dates_array.each do |date|
          date_string = date.strftime('%Y-%m-%d')
          job_id = async_stats_job_id(batched_campaign_ids, date)
          if job_id.present?
            job_done = false
            begin
              stats_res = check_stats_res(job_id)
              status = begin stats_res.body[:data].first[:status] rescue nil end
              url = begin stats_res.body[:data].first[:url] rescue nil end
              puts "> status: " + status.inspect
              puts "> url: " + url.inspect
              if status.nil? # failed request
                job_done = nil
              elsif url.present? # successful request
                job_done = true
                infile = open(url)
                gz = Zlib::GzipReader.new(infile)
                gz.each_line do |line|
                  parsed_line = JSON.parse(line)
                  all_stats = parsed_line["data"]
                  # puts "> all_stats: " + all_stats.inspect
                  all_stats.each do |stats|
                    metrics = stats["id_data"].first["metrics"]
                    puts "> metrics: " + metrics.inspect
                    campaign_id = stats["id"]
                    campaign = campaigns.select{|campaign| campaign[:id] == campaign_id}.first
                    impressions = begin metrics["impressions"].first rescue nil end
                    total_spend = begin metrics["billed_charge_local_micro"].first rescue nil end
                    billed_spend = total_spend ? (total_spend.to_f/1000000).round(2) : nil
                    ga_data = GoogleAnalytics.fetch_and_parse_metrics(date_string, date_string, self.client.google_analytics_view_id, campaign[:name])
                    data_rows.push(
                      [ date_string,
                        account.name,
                        campaign[:name],
                        campaign[:entity_status],
                        (impressions ? impressions : '-'),
                        (billed_spend ? billed_spend : '-'),
                        calculate_cpm(billed_spend, impressions)
                      ].concat(ga_data[:data_rows].first)
                    )
                  end
                end
              else # request processing; try again shortly
                sleep 2.seconds
              end
            end while job_done == false
          else
            return { error: "Could not fetch an async job ID from the Twitter API." }
          end
        end
      end

      puts "> data_rows: " + data_rows.inspect
      return { csv: to_csv(headers, data_rows) }
    
    rescue => e
      # if a problem occurs, log the exception to Rollbar and return a
      # message to ReportWorker to put in the dataset's status explanation
      Rollbar.log(e)
      return { error: (e.try(:message) || e.try(:response) || e.inspect) }
    end
  end

  private

  def twitter_credentials
    TwitterAds::Client.new(
      ENV['TWITTER_CONSUMER_KEY'],
      ENV['TWITTER_CONSUMER_SECRET'],
      ENV['TWITTER_ACCESS_TOKEN'],
      ENV['TWITTER_ACCESS_TOKEN_SECRET']
    )
  end

  def format_date(date_string, timezone)
    datetime = Time.parse(date_string)
    return DateTime.new(datetime.year, datetime.month, datetime.day, 0, 0, 0, timezone)
  end

  def get_campaigns(account_id)
    campaigns_req = TwitterAds::Request.new(twitter_credentials, :get, "/1/accounts/#{account_id}/campaigns")
    campaigns_result = campaigns_req.perform
    campaigns = campaigns_result.body[:data]
    return campaigns.select{|campaign| 
      !campaign[:reasons_not_servable].include?('EXPIRED') && !campaign[:reasons_not_servable].include?('BUDGET_EXHAUSTED')
    }
  end

  def async_stats_job_id(campaign_ids, date)
    async_stats_req = TwitterAds::Request.new(twitter_credentials, :post, "/1/stats/jobs/accounts/#{self.uid}", {params: {
      entity: 'CAMPAIGN',
      entity_ids: campaign_ids.join(","),
      start_time: date.strftime('%Y-%m-%d'),
      end_time: (date + 1.day).strftime('%Y-%m-%d'),
      granularity: 'TOTAL',
      placement: 'ALL_ON_TWITTER',
      metric_groups: 'ENGAGEMENT,BILLING'
    }})
    async_stats_res = async_stats_req.perform
    job_id = begin async_stats_res.body[:data][:id_str] rescue nil end
    return job_id
  end

  def check_stats_res(job_id)
    stats_req = TwitterAds::Request.new(twitter_credentials, :get, "/1/stats/jobs/accounts/#{self.uid}", params: {
      job_ids: job_id
    })
    return stats_req.perform
  end

  def calculate_cpm(spend, impressions)
    if spend.present? && impressions.present? && spend != '-' && impressions != '-'
      return ((spend/impressions) * 1000).round(2)
    else
      return '-'
    end
  end

  def to_csv(header_row, data_rows)
    csv_report = CSV.generate do |csv|
      csv << header_row
      data_rows.each do |data_row|
        csv << data_row
      end
    end
    return csv_report
  end
end
