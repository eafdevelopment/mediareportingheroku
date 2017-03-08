class ReportWorker
  include Sidekiq::Worker

  def perform(report_id)
    dataset = Dataset.find(report_id)
    cc = dataset.client_channel
    # report_data = cc.generate_report_all_campaigns(params[:date_from], params[:date_to])
    # store csv instead of send it back
  end 

end
