class ReportWorker
  include Sidekiq::Worker

  def perform(report_id, from, to)
    dataset = Dataset.find(report_id)
    cc = dataset.client_channel
    begin
      # store csv as dataset attachment
      report_data = cc.generate_report_all_campaigns(from, to)
      # dataset.update(csv: StringIO.new(report_data))

      csv_file = StringIO.new(report_data)
      dataset.csv = csv_file
      dataset.csv_content_type = 'text/csv'
      dataset.csv_file_name = 'my file name.csv'
      dataset.save!
    rescue => e
      puts e.message
      puts e.backtrace
    end
  end 

end
