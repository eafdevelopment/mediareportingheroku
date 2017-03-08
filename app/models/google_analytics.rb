module GoogleAnalytics

  def self.fetch_and_parse_metrics(from_date, to_date, uid, campaign_name)
    # Find and return metrics from a view in a Google Analytics account
    # - the uid argument here represents the GA View ID, and the campaign_name
    # is for filtering data within that view (eight&four would go to Reporting >
    # Acquisition > Campaigns in Google Analytics to see the data they want)
    #
    # IMPORTANT: GA allows us to request up to 5 reports, but currently our
    # app will only look at the first returned report
    header_rows = AppConfig.google_analytics_headers.for_csv.map(&:first)
    if header_rows.any?
      grr = Google::Apis::AnalyticsreportingV4::GetReportsRequest.new
      report_requests = []
      # generate one ReportRequest for each group of up to 10 metrics
      header_rows.each_slice(10) do |header_group|
        rr = Google::Apis::AnalyticsreportingV4::ReportRequest.new
        rr.view_id = uid
        rr.metrics = header_group.map{ |header| self.metric(header) }
        rr.date_ranges = [self.date_range(from_date, to_date)]
        rr.filters_expression = "ga:campaign==" + campaign_name
        rr.dimensions = [self.dimension("ga:day")]
        rr.include_empty_rows = true
        report_requests.push(rr)
      end
      # we can request up to 5 reports at a time
      combined_parsed_report = {
        header_row: [],
        data_rows: []
      }
      report_requests.each_slice(5) do |report_request_group|
        grr.report_requests = report_request_group
        response = self.google_client.batch_get_reports(grr)
        response.reports.each do |report|
          parsed_report = self.parse_metrics(report)
          # each parsed report should contain the same number of rows of data,
          # which each need to be concatenated with the equivalent rows in
          # the other reports here, to create one final combined report to return
          combined_parsed_report[:header_row].concat(parsed_report[:header_row])
          parsed_report[:data_rows].each_with_index do |data_row, index|
            if combined_parsed_report[:data_rows][index].present?
              # our combined report already contains the start of this data row
              combined_parsed_report[:data_rows][index].concat(data_row)
            else
              # our combined report doesn't yet contain a row for this data
              combined_parsed_report[:data_rows][index] = data_row
            end
          end
        end unless response.reports.nil?
      end
      return combined_parsed_report
    end
    # if we haven't been able to successfully return data, return an
    # empty object
    return {
      header_row: [],
      data_rows: []
    }
  end

  private

  def self.google_client
    creds = Google::Auth::ServiceAccountCredentials.make_creds({
      :json_key_io => StringIO.new(ENV["GOOGLE_CLIENT_SECRETS"]),
      :scope => "https://www.googleapis.com/auth/analytics.readonly"
    })
    client = Google::Apis::AnalyticsreportingV4::AnalyticsReportingService.new
    client.authorization = creds
    return client
  end

  def self.date_range(start_date, end_date)
    range = Google::Apis::AnalyticsreportingV4::DateRange.new
    range.start_date = Date.parse(start_date)
    range.end_date = Date.parse(end_date)
    return range
  end

  def self.dimension(name)
    dimension = Google::Apis::AnalyticsreportingV4::Dimension.new
    dimension.name = name
    return dimension
  end

  def self.metric(expression)
    metric = Google::Apis::AnalyticsreportingV4::Metric.new
    metric.expression = expression
    return metric
  end

  def self.parse_metrics(report)
    # first, check whether the report contains rows of data or just a 'totals'
    # row full of zeroes
    if report.data.try(:rows)
      data_rows = report.data.rows.map{|row| row.metrics.map{|metrics_row| metrics_row.values}.flatten }
    else
      data_rows = report.data.totals.map{|total| total.values}
    end
    parsed_metrics = {
      header_row: report.column_header.metric_header.metric_header_entries.map{|header| header.name},
      data_rows: data_rows,
    }
    # Some of the metrics Google Analytics gives us should be modified
    # for display in the front-end
    parsed_metrics[:header_row].each_with_index do |header, index|
      case header
      when "ga:avgSessionDuration"
        # Google gives us an avgSessionDuration in seconds, e.g. 36.92846216
        # which we need to turn into a readable time value, e.g. 00:00:37
        parsed_metrics[:data_rows].each do |data_row|
          avg_session_duration = data_row[index].to_f.round
          data_row[index] = Time.at(avg_session_duration).utc.strftime("%H:%M:%S")
        end
      when "ga:bounceRate"
        parsed_metrics[:data_rows].each do |data_row|
          data_row[index] = data_row[index].to_f.round(2)
        end
      when "ga:pageviewsPerSession"
        parsed_metrics[:data_rows].each do |data_row|
          data_row[index] = data_row[index].to_f.round(2)
        end
      end
    end
    # Lastly, switch each "ga:" header for it's nicer name
    parsed_metrics[:header_row].each_with_index do |header, index|
      parsed_metrics[:header_row][index] = AppConfig.google_analytics_headers.for_csv[header]
    end
    return parsed_metrics
  end
end