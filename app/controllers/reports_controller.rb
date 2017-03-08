# Reports Controller manages API calls and fetching of the data
# It is then displayed on the reports index, or search results page, and 
# will also respond with a CSV download of raw data
require 'csv'

class ReportsController < ApplicationController

  def index
    @reports = Dataset.all.order(created_at: :desc)
    # cc = ClientChannel.find_by(id: params[:channel])
    # report_data = cc.generate_report_all_campaigns(params[:date_from], params[:date_to])
    # send_data report_data, filename: file_name(cc)
  end

  private

  def file_name(cc)
    cc.client.name.gsub(/\W+/, "_") + "_" + cc.nice_name + "_" + params[:date_from].gsub(/\W+/, "") + "_" + params[:date_to].gsub(/\W+/, "") + ".csv"
  end
end
