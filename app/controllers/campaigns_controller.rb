class CampaignsController < ApplicationController

  before_action :find_client, only: :new

  def new
    @campaign = Campaign.new
    @client_channels = @client.client_channels.all

    # @campaign_channels = []
    # 5.times do
    #   @kennel << CampaignChannel.new
    # end


    @channels = Hash.new
    @client_channels.each do |channel|     
      @channels[channel] = CampaignChannel.new
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
      flash[:notice] = "There was a problem creating the campaign"
      redirect_to :back
      # render :new
    end
  end

  private

  def campaign_params
    params.require(:campaign).permit(:name, campaign_channels_attributes: [:client_channel_id, :uid])
  end

  def find_client
    @client = Client.find(params[:client])
  end
end
