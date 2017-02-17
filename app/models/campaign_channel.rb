class CampaignChannel < ApplicationRecord

  # Relations
  belongs_to :client_channel, inverse_of: :campaign_channels
  belongs_to :campaign, inverse_of: :campaign_channels

  validates :uid, presence: true
  
end
