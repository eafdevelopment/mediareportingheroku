class ReportsController < ApplicationController

  def index
    @client = Client.find(params[:client])
    @campaign = Campaign.find(params[:campaign])
    dmu_on_facebook = Facebook.new(@client)
    @insights = dmu_on_facebook.fetch_insights({
      campaign_id: @campaign.facebook_campaign_id,
      fromDate: params[:date_from],
      startDate: params[:date_to]
    })
    puts @insights
  end
end
