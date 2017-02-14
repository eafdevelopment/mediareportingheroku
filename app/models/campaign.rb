class Campaign < ApplicationRecord
  belongs_to :client, inverse_of: :campaigns
end
