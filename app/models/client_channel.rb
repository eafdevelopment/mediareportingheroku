# ClientChannel connects a client to their relevant reporting channels
# For example Client DMU International has a client channel - DMU International Facebook -
# that stores their UID for the relevant DMU International account on Facebook

class ClientChannel < ApplicationRecord

  # Relationships
  belongs_to :client, inverse_of: :client_channels
  has_many :campaign_channels, inverse_of: :client_channel

  # Validations
  validates :uid, presence: true

  # Methods
  def nice_name
    self.class.name.split('::').last
  end
end
