require 'google/apis/analyticsreporting_v4'
require 'googleauth'

include Google::Apis::AnalyticsreportingV4
include Google::Auth

class ClientChannels::GoogleAnalytics < ClientChannel

  def fetch_metrics(params)
    # Find and return metrics from a view in a Google Analytics account
    # params = { uid: 'xyz', fromDate: '7daysAgo', startDate: 'today' }
    grr = GetReportsRequest.new
    rr = ReportRequest.new
    rr.view_id = params[:uid]
    rr.metrics = [metric("ga:sessions"), metric("ga:sessionDuration")]
    rr.date_ranges = [dateRange("7daysAgo", "today")]
    grr.report_requests = [rr]
    response = client.batch_get_reports(grr)
    response.reports.each do |report|
      report.data.rows.each do |row|
        puts row
      end
    end
  end

  private

  def client
    creds = ServiceAccountCredentials.make_creds({
      :json_key_io => File.open(Rails.root.join('client_secrets_4023d7d9e162.json').to_s),
      :scope => 'https://www.googleapis.com/auth/analytics.readonly'
    })
    client = AnalyticsReportingService.new
    client.authorization = creds
    return client
  end

  def dateRange(startDate, endDate)
    range = DateRange.new
    range.start_date = startDate
    range.end_date = endDate
    return range
  end

  def metric(expression)
    metric = Metric.new
    metric.expression = expression
    return metric
  end

end