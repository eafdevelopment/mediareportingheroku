class ClientChannelsController < ApplicationController

  def index
    # this route receives AJAX $.get requests to update
    # the New Report form fields on home#index

    client = Client.find_by(id: params[:client_id])
    @client_channels = client.client_channels

    respond_to do |format|
      format.js 
    end
  end
end