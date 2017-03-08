# Dataset model store CSV reports generated for different client channels
# They belong to a client channel, had a title and attached file stored in 
# an AWS S3 bucket

class Dataset < ApplicationRecord

  belongs_to :client_channel, inverse_of: :datasets
  has_attached_file :csv

  validates_attachment :csv, content_type: { content_type: "text/csv" }
end
