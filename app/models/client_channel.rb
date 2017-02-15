class ClientChannel < ApplicationRecord

  # Relationships

  belongs_to :client, inverse_of: :client_channels

  # Validations



  # Methods

end
