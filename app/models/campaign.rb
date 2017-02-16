class Campaign < ApplicationRecord
  belongs_to :client, inverse_of: :campaigns
  has_many :campaign_channels, inverse_of: :campaign

  validates_uniqueness_of :name
end
