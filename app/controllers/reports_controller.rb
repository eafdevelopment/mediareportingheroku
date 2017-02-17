class ReportsController < ApplicationController

  def index
    @client = Client.find(params[:client])
    @campaign = Campaign.find(params[:campaign])
    # we should receive an array of client_channels so we could perhaps loop through
    # them to build a big ol' metrics object for the view to display everything?
    # for now, we'll just fetch one client channel's metrics
    @results = {}
    # client_channel = @client.client_channels.find_by(type: params[:channel])
    # puts "\n> client_channel: " + client_channel.inspect
    # @metrics[client_channel] = client_channel.fetch_metrics({
    #   uid: client_channel.uid,
    #   fromDate: params[:date_from],
    #   startDate: params[:date_to]
    # })
    # puts "\n> @metrics: " + @metrics
  end

end
