# Campaigns sit under a client and have a relation to the CampaignChannels
# they are associated with
# eight&four can create a new campaign, belonging to one of their existing clients,
# and save the relevant UIDs for each of the channels they are using to track it
# Campaigns may or may not run accross all the channels they use for that client

class CampaignsController < ApplicationController

  before_action :find_client
  before_action :find_campaign, only: [:edit, :update]

  def index
    # this route receives AJAX $.get requests to update
    # the New Report form fields on home#index
    client = Client.find_by(id: params[:client_id])
    @campaigns = client.campaigns
    respond_to do |format|
      format.js
    end
  end
  
  def new
    @campaign = Campaign.new
    @client_channels = @client.client_channels.all
    @client_channels.each do |client_channel|
      @campaign.campaign_channels.build(client_channel: client_channel)
    end
  end

  def create
    remove_ignored_uid_fields!(params[:campaign]["campaign_channels_attributes"])
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
    @client_channels.each do |client_channel|
      campaign_channels = @campaign.campaign_channels.map{ |c| c.client_channel }
      unless campaign_channels.include?(client_channel)
        @campaign.campaign_channels.build(client_channel: client_channel)
      end
    end
  end

  def update
    remove_ignored_uid_fields!(params[:campaign]["campaign_channels_attributes"])
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
    params.require(:campaign).permit(:name, campaign_channels_attributes: [:id, :client_channel_id, :google_analytics_campaign_name, :uid])
  end

  def find_client
    @client = Client.find(params[:client_id])
  end

  def find_campaign
    @campaign = Campaign.find(params[:id])
  end
end
