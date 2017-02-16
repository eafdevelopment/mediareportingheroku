class CampaignsController < ApplicationController

  before_action :find_client, only: :new

  def new
    @campaign = Campaign.new
    @client_channels = @client.client_channels.all
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
    params.require(:campaign).permit(:name)
  end

  def find_client
    @client = Client.find(params[:client])
  end
end
