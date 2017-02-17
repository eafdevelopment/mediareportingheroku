class CampaignsController < ApplicationController

  before_action :find_client

  def new
    @campaign = Campaign.new
    @client_channels = @client.client_channels.all
    @client_channels.each do |client_channel|
      @campaign.campaign_channels.build(client_channel: client_channel)
    end
  end

  def create
    # Create the campaign
    @campaign = Campaign.new(campaign_params)
    @campaign.client = @client
    if @campaign.save
      # Save the campaign channels here
      redirect_to clients_path
    else
      render :new
    end
  end

  private

  def campaign_params
    params.require(:campaign).permit(:name, campaign_channels_attributes: [:client_channel_id, :uid])
  end

  def find_client
    @client = Client.find(params[:client_id])
  end
end
