class Client < ApplicationRecord
  has_many :campaigns, inverse_of: :client, dependent: :destroy
end
