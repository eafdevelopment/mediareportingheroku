# Clients are currently seeded into the database along with the ClientChannels
# that they are using. 
# Campaigns can be created under a client within the Campaigns Controller
# Generating a client report begins by selecting the client it is being made for, 
# and then narrowing down which campaign and channel metrics should be included

class ClientsController < ApplicationController
  before_action :find_client, only: [:show, :edit, :update, :destroy]
  before_action :remove_ignored_client_channel_uids, only: [:create, :update]

  def index
    @clients = Client.all.order(name: :desc)
  end

  def new
    @client = Client.new
    AppConfig.client_channel_subclasses.each do |subclass|
      @client.client_channels.build(type: subclass)
    end
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
    AppConfig.client_channel_subclasses.each do |subclass|
      @client.client_channels.build(type: subclass) unless @client.client_channels.find_by(type: subclass)
    end
  end

  def update
    # TODO: This needs to be adjusted so a user can delete the value and it
    # saves in the db as opposed to ignoring the empty string
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
    params.require(:client).permit(:name, :google_analytics_view_id, client_channels_attributes: [:id, :type, :uid])
  end

  def find_client
    @client = Client.find(params[:id])
  end

  # Internal: Remove any nested client channels that have empty UIDs, so that
  # they don't fail validations when the user doesn't want to add them.
  def remove_ignored_client_channel_uids
    remove_ignored_uid_fields!(params[:client][:client_channels_attributes]) if params[:client]
    true
  end
end
