class ReportsController < ApplicationController

  def index
    @client = Client.find(params[:client])
    @campaign = Campaign.find(params[:campaign])
  end
end
