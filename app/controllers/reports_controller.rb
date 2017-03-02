# Reports Controller manages API calls and fetching of the data
# It is then displayed on the reports index, or search results page, and 
# will also respond with a CSV download of raw data
require 'csv'

class ReportsController < ApplicationController

  before_action :check_date, only: :index

  def index
    cc = ClientChannel.find_by(id: params[:channel])
    report_data = cc.generate_report_all_campaigns(params[:date_from], params[:date_to])
    send_data report_data, filename: 'report.csv'
  end

  private

  def valid_date_range
    if params[:date_from].present? && params[:date_to].present?
      from = Date.parse(params[:date_from])
      to = Date.parse(params[:date_to])
      if from <= to
        return true
      end
    end
  end

  def check_date
    unless valid_date_range
      flash[:alert] = "Invalid date range."
      redirect_back(fallback_location: root_path) and return
    end
  end

  def file_name(client_channels)
    channel = client_channels.first.class.name.split('::').last
    "#{@client.name}_#{channel}_report_from_#{params[:date_from]}_to_#{params[:date_to]}.csv"
  end
end
