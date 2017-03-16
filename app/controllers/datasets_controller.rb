class DatasetsController < ApplicationController

  before_action :check_date, only: :create

  # Create and store a csv report 
  def create
    cc = ClientChannel.find_by(id: params[:channel])
    @dataset = Dataset.new(title: file_name(cc), client_channel: cc, status: 'generating')
    if @dataset.save
      # Begin ClientChannel get report method in the background ReportWorker
      job_id = ReportWorker.perform_async(@dataset.id, params[:date_from], params[:date_to])
      @dataset.update(job_id: job_id.to_s)
      flash[:notice] = "Report generating. Please refresh the page to check it's status"
      redirect_to reports_path and return
    else
      flash[:notice] = "There was a problem creating your report"
      redirect_to root_path
    end
  end

  def destroy
    dataset = Dataset.find(params[:id])
    dataset.destroy!
    flash[:notice] = "Report deleted"
    redirect_to reports_path
  end

  def download
    dataset = Dataset.find(params[:id])
    redirect_to dataset.csv.expiring_url(10)
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