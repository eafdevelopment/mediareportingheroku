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
    remove_ignored_campaign_channels
    # Create the campaign & campaign channels
    @campaign = Campaign.new(campaign_params)
    @campaign.client = @client
    if @campaign.save
      redirect_to clients_path
    else
      render :new
    end
  end

  def edit
    @campaign = Campaign.find(params[:id])
    @client_channels = @client.client_channels.all
  end

  def destroy
    campaign = Campaign.find(params[:id])
    campaign.destroy!
    redirect_to clients_path
  end

  private

  def campaign_params
    if params[:campaign][:campaign_channels_attributes][:uid] == ""
      puts 'HI THERE THE BELOW'
      puts params[:campaign]
    end

    params.require(:campaign).permit(:name, campaign_channels_attributes: [:client_channel_id, :uid])
  end

  def find_client
    @client = Client.find(params[:client_id])
  end

  def remove_ignored_campaign_channels
    params[:campaign]["campaign_channels_attributes"].each do |k, v|
      if v[:uid] == ""
        params[:campaign]['campaign_channels_attributes'].delete k
      end
    end
  end
end
