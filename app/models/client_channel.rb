class ClientChannel < ApplicationRecord

  # Relationships
  belongs_to :client, inverse_of: :client_channels
  has_many :campaign_channels, inverse_of: :client_channel

  # Validations
  validates :uid, presence: true, uniqueness: true

  # Methods

end
