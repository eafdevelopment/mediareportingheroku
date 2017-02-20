class HomeController < ApplicationController

  def index
    @clients = Client.all.order(name: :desc)
  end

  def update_campaigns
    @campaigns = Campaign.where(client_id: params[:client_id])
    respond_to do |format|
      format.js
    end
  end

  def update_campaign_channels
    @campaign_channels = CampaignChannel.where(campaign_id: params[:campaign_id])
    respond_to do |format|
      format.js
    end
  end
  
end
