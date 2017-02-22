# Home index is the landing page with report search form

class HomeController < ApplicationController

  def index
    @clients = Client.all.order(name: :desc)
  end
  
end
