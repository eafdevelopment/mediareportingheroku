# Dataset model stores CSV reports generated for different client channels.
# They belong to a client channel, have a title and attached file stored in 
# an AWS S3 bucket

class Dataset < ApplicationRecord

  # Relationships

  belongs_to :client_channel, inverse_of: :datasets
  
  has_attached_file :csv,
    s3_permissions: :private,
    s3_headers: lambda { |attachment|
      {
        "Content-Disposition": %(attachment; filename="#{attachment.csv_file_name}"),
        "Content-Type": "text/csv"
      }
    }

  # Validations

  validates_attachment :csv, content_type: { content_type: "text/csv" }
  validates_inclusion_of :status, in: %w( generating done failed )
end
