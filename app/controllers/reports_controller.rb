class ReportsController < ApplicationController

  def index
    unless valid_date_range
      flash[:alert] = "Invalid date range."
      redirect_back(fallback_location: root_path) and return
    end
    @client = Client.find(params[:client])
    @campaign = Campaign.find(params[:campaign])
    # we should receive an array of client_channels so we could perhaps loop through
    # them to build a big ol' metrics object for the view to display everything?
    # for now, we'll just fetch one client channel's metrics
    @results = []
    client_channels = @client.client_channels.where(type: params[:channel])
    campaign_channels = @campaign.campaign_channels.where(client_channel_id: client_channels.map(&:id))
    campaign_channels.each do |campaign_channel|
      @results.push(campaign_channel.client_channel.fetch_metrics(params[:date_from], params[:date_to], campaign_channel.uid))
    end
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
