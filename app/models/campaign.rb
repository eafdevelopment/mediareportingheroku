# Campaign is an individual report for eight&four, which is always associated 
# to a single client. Clients have many campaigns.

class Campaign < ApplicationRecord
  belongs_to :client, inverse_of: :campaigns
  has_many :campaign_channels, inverse_of: :campaign, dependent: :destroy

  accepts_nested_attributes_for :campaign_channels
  validates_uniqueness_of :name, scope: :client
end
