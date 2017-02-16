class ClientsController < ApplicationController

  def index
    @clients = Client.all.order(name: :desc)
  end

  def show
  end
end
