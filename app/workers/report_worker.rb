class ReportWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options :retry => 1

  def perform(report_id, from, to)
    dataset = Dataset.find(report_id)
    cc = dataset.client_channel

    # attempt to fetch report data
    report_data_result = cc.generate_report_all_campaigns(from, to)

    if report_data_result[:error].present?
      # report fetch failed, so update dataset accordingly
      dataset.status = 'failed'
      dataset.status_explanation = report_data_result[:error]
    elsif report_data_result[:csv].present?
      # fetched report data, so store csv as dataset attachment
      csv_file = StringIO.new(report_data_result[:csv])
      dataset.csv = csv_file
      dataset.csv_content_type = 'text/csv'
      dataset.csv_file_name = dataset.title
      dataset.status = 'done'
    end
    
    dataset.save!
  end 

end
