# This worker runs every x hours to check "generating" datasets
# and see whether their status needs updating to "complete" or
# "failed"

class ReportStatusCheckWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options :retry => 1

  def perform
    begin
      # pull any datasets created over an hour ago that are still "generating"
      Dataset.where("created_at < ? AND status = ?", 1.hour.ago, "generating").each do |dataset|
        if dataset.csv.present?
          dataset.update_attributes(status: "done")
        else
          # if no CSV but job exists in Sidekiq, check job status & update dataset status
          job_status = Sidekiq::Status::get_all dataset.job_id
          if job_status.present?
            case job_status
            when "complete"
              dataset.update_attributes(status: "done")
            when "working" || "queued"
              # ... leave this dataset's status as "generating"
            when "failed" || "interrupted"
              dataset.update_attributes(status: "failed")
            end
          else
            # if no CSV and no job in Sidekiq, dataset is "failed"
            dataset.update_attributes(status: "failed")
          end
        end
      end
    rescue => e
      Rollbar.error(e)
    end
  end 
end

Sidekiq::Cron::Job.create(
  class: 'ReportStatusCheckWorker',
  cron: '0 * * * *',
  name: 'Report Status Check Worker - every hour'
)