class HomeController < ApplicationController

  def index
    @clients = Client.all.order(name: :desc)
    @campaigns = Campaign.all.order(name: :desc)
  end

  def update_campaigns
    @campaigns = Campaign.where(client_id: params[:client_id])
    respond_to do |format|
      format.js
    end
  end
end
