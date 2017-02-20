# Clients are currently seeded into the database along with the ClientChannels
# that they are using. 
# Campaigns can be created under a client within the Campaigns Controller
# Generating a client report begins by selecting the client it is being made for, 
# and then narrowing down which campaign and channel metrics should be included

class ClientsController < ApplicationController

  def index
    @clients = Client.all.order(name: :desc)
  end

  def show
  end
end
