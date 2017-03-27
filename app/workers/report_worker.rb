class ReportWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options :retry => 1

  def perform(report_id, from, to)
    dataset = Dataset.find(report_id)
    cc = dataset.client_channel
    job_id = dataset.job_id

    begin
      # store csv as dataset attachment
      report_data = cc.generate_report_all_campaigns(from, to)
      csv_file = StringIO.new(report_data)

      dataset.csv = csv_file
      dataset.csv_content_type = 'text/csv'
      dataset.csv_file_name = dataset.title
      job_status = Sidekiq::Status::get_all job_id
      puts job_status

      dataset.status = 'done'
      dataset.save!
    rescue => exception
      # catch failed background jobs and update status
      dataset.status = 'failed'
      api_response = exception.try(:response)
      
      if api_response # if exception from API error
        parsed_response = JSON.parse(api_response)
        dataset.status_explanation = parsed_response["message"]
        Rollbar.error(parsed_response)
      else
        dataset.status_explanation = exception.message
        Rollbar.error(e)
      end
      
      dataset.save
    end
  end 

end
