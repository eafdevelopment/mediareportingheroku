# Clients are currently seeded into the database along with the ClientChannels
# that they are using. 
# Campaigns can be created under a client within the Campaigns Controller
# Generating a client report begins by selecting the client it is being made for, 
# and then narrowing down which campaign and channel metrics should be included

class ClientsController < ApplicationController

  before_action :find_client, only: [:show, :edit, :update, :destroy]

  def index
    @clients = Client.all.order(name: :desc)
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)
    if @client.save
      flash[:notice] = "Client successfully created."
      redirect_to clients_path
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @client.update(client_params)
      flash[:notice] = "Client successfully updated."
      redirect_to client_path(@client)
    else
      render :edit
    end
  end

  def destroy
    @client.destroy!
    redirect_to clients_path
  end

  private

  def client_params
    params.require(:client).permit(:name, :google_analytics_view_id)
  end

  def find_client
    @client = Client.find(params[:id])
  end

end
