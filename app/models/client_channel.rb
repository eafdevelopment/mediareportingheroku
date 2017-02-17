class ClientChannel < ApplicationRecord

  # Relationships

  belongs_to :client, inverse_of: :client_channels

  # Validations

  validates_uniqueness_of :uid

  # Methods

end
