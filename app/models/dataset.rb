# Dataset model store CSV reports generated for different client channels
# They belong to a client channel, had a title and attached file stored in 
# an AWS S3 bucket

class Dataset < ApplicationRecord

  belongs_to :client_channel, inverse_of: :datasets
  has_attached_file :csv,
    s3_permissions: :private,
    s3_protocol: :https,
    s3_headers: lambda { |attachment|
      {
        "Content-Disposition": %(attachment; filename="#{attachment.csv_file_name}"),
        "Content-Type": "text/csv"
      }
    }

  validates_attachment :csv, content_type: { content_type: "text/csv" }
end
