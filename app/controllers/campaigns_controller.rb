# Campaigns sit under a client and have a relation to the CampaignChannels
# they are associated with
# eight&four can create a new campaign, belonging to one of their existing clients,
# and save the relevant UIDs for each of the channels they are using to track it
# Campaigns may or may not run accross all the channels they use for that client

class CampaignsController < ApplicationController

  before_action :find_client
  before_action :find_campaign, only: [:edit, :update]

  def new
    @campaign = Campaign.new
    @client_channels = @client.client_channels.all
    @client_channels.each do |client_channel|
      @campaign.campaign_channels.build(client_channel: client_channel)
    end
  end

  def create
    remove_ignored_campaign_channels!
    # Create the campaign & campaign channels
    @campaign = Campaign.new(campaign_params)
    @campaign.client = @client
    if @campaign.save
      flash[:notice] = "Campaign successfully created"
      redirect_to clients_path
    else
      render :new
    end
  end

  def edit
    @client_channels = @client.client_channels.all
  end

  def update
    if @campaign.update(campaign_params)
      flash[:notice] = "Campaign successfully updated"
      redirect_to clients_path
    else
      render :edit
    end
  end

  def destroy
    campaign = Campaign.find(params[:id])
    campaign.destroy!
    redirect_to clients_path
  end

  private

  def campaign_params
    params.require(:campaign).permit(:name, campaign_channels_attributes: [:id, :client_channel_id, :uid])
  end

  def find_client
    @client = Client.find(params[:client_id])
  end

  def find_campaign
    @campaign = Campaign.find(params[:id])
  end

  def remove_ignored_campaign_channels!
    params[:campaign]["campaign_channels_attributes"].each do |k, v|
      if v[:uid] == ""
        params[:campaign]['campaign_channels_attributes'].delete k
      end
    end
  end
end
