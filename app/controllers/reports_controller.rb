# Reports Controller manages API calls and fetching of the data
# It is then displayed on the reports index, or search results page, and 
# will also respond with a CSV download of raw data
require 'csv'

class ReportsController < ApplicationController

  before_action :check_date, only: :index

  def index
    flash[:notice] = 'We are dealing with your search...'
    redirect_back(fallback_location: root_path) and return
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

  def csv_download(csv_report)
    CSV.generate do |csv|
      csv << csv_report[:header_row]
      csv_report[:data_rows].each do |data_row|
        csv << data_row
      end
    end
  end

  def file_name(client_channels)
    channel = client_channels.first.class.name.split('::').last
    "#{@client.name}_#{channel}_report_from_#{params[:date_from]}_to_#{params[:date_to]}.csv"
  end
end
