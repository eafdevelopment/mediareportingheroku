# Client is the equivalent to an account on one of the reporting platforms
# E.g. DMU International. 
# It has many campaigns and many client channels that they use for tracking 
# camaign metrics under this account

class Client < ApplicationRecord
  has_many :campaigns, inverse_of: :client, dependent: :destroy
  has_many :client_channels, inverse_of: :client
  accepts_nested_attributes_for :client_channels
end
