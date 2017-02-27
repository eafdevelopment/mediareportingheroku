# CampaignChannel connects a campaign with it's relevant reporting channels,
# storing the unique id, name, or reference for that particular campaign
# on that channel
# E.g. Campaign1 has a CampaignChannel of Campaign1 Facebook for the unique 
# campaign id and fetching campaign metrics

class CampaignChannel < ApplicationRecord

  # Relations
  belongs_to :client_channel, inverse_of: :campaign_channels
  belongs_to :campaign, inverse_of: :campaign_channels

  # Validations
  validates :uid, presence: true
  
end
