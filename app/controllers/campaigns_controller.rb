class CampaignsController < ApplicationController

  before_action :find_client, only: :create

  def new
    @clients = Client.all
    @campaign = Campaign.new
  end

  def create
    @campaign = Campaign.new(campaign_params)
    @campaign.client = @client
    if @campaign.save
      redirect_to clients_path
    else
      @clients = Client.all
      render :new
    end
  end

  private

  def campaign_params
    params.require(:campaign).permit(:name)
  end

  def find_client
    @client = Client.find(params[:campaign][:client])
  end
end
