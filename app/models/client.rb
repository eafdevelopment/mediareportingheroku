class Client < ApplicationRecord
  has_many :campaigns, inverse_of: :client, dependent: :destroy
  has_many :client_channels, inverse_of: :client
end
