class ReportsController < ApplicationController

  def index
    @client = Client.find(params[:client])
    @campaign = Campaign.find(params[:campaign])
    # we should receive an array of client_channels so we could perhaps loop through
    # them to build a big ol' metrics object for the view to display everything?
    # for now, we'll just fetch one client channel's metrics
    @results = []
    client_channels = @client.client_channels.where(type: params[:channel])
    campaign_channels = @campaign.campaign_channels.where(client_channel_id: client_channels.map(&:id))
    puts "\n> client_channels: " + client_channels.inspect
    puts "\n> campaign_channels: " + campaign_channels.inspect
    campaign_channels.each do |campaign_channel|
      @results.push(
        campaign_channel.client_channel.fetch_metrics({
          uid: campaign_channel.uid,
          fromDate: params[:date_from],
          startDate: params[:date_to]
        })
      )
    end
    puts "\n> @results: " + @results.inspect
    @results.each do |thing|
      puts ">> thing: " + thing.inspect
      # thing.each do |thing2|
      #   puts ">>> thing2: " + thing2.inspect
      # end
    end
  end

end
