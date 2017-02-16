class ReportsController < ApplicationController

  def index
    @client = Client.find(params[:client])
    @campaign = Campaign.find(params[:campaign])
    client_facebook = @client.client_channels.find_by(type: "ClientChannels::Facebook")
    @insights = client_facebook.fetch_insights({
      campaign_id: params[:uid],
      fromDate: params[:date_from],
      startDate: params[:date_to]
    })
    client_google_analytics = @client.client_channels.find_by(type: "ClientChannels::GoogleAnalytics")
    @analytics = client_google_analytics.fetch_metrics({
      view_id: params[:uid],
      fromDate: params[:date_from],
      startDate: params[:date_to]
    })
    puts @insights
  end
end
