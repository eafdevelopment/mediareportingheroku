class DatasetsController < ApplicationController

  before_action :check_date, only: :create

  # Create and store a csv report 
  def create
    cc = ClientChannel.find_by(id: params[:channel])
    @dataset = Dataset.new(title: file_name(cc), client_channel: cc)
    if @dataset.save
      # Begin ClientChannel get report method in the background ReportWorker
      ReportWorker.perform_async(@dataset.id)
      flash[:notice] = "Report generating..."
      redirect_to reports_path and return
    else
      flash[:notice] = "There was a problem creating your report"
      redirect_to root_path
    end
  end

  private

  def file_name(cc)
    cc.client.name.gsub(/\W+/, "_") + "_" + cc.nice_name + "_" + params[:date_from].gsub(/\W+/, "") + "_" + params[:date_to].gsub(/\W+/, "") + ".csv"
  end

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
end