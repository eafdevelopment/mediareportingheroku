# Reports Controller manages API calls and fetching of the data
# It is then displayed on the reports index, or search results page, and 
# will also respond with a CSV download of raw data

class ReportsController < ApplicationController

  def index
    unless valid_date_range
      flash[:alert] = "Invalid date range."
      redirect_back(fallback_location: root_path) and return
    end
    @client = Client.find(params[:client])
    @campaign = Campaign.find(params[:campaign])
    client_channels = @client.client_channels.where(type: params[:channel])
    campaign_channels = @campaign.campaign_channels.where(client_channel_id: client_channels.map(&:id))
    @summary_report = Report.build_summary_report(params[:date_from], params[:date_to], campaign_channels)
  end

  private

  def valid_date_range
    if params[:date_from].present? && params[:date_to].present?
      from = Date.parse(params[:date_from])
      to = Date.parse(params[:date_to])
      if from <= to
        return true
      end
    end
  end

end
