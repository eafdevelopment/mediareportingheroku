class Campaign < ApplicationRecord
  belongs_to :client, inverse_of: :campaigns

  validates_uniqueness_of :name
end
