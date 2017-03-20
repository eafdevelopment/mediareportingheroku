# ClientChannel connects a client to their relevant reporting channels
# For example Client DMU International has a client channel - DMU International Facebook -
# that stores their UID for the relevant DMU International account on Facebook

class ClientChannel < ApplicationRecord

  # Relationships
  belongs_to :client, inverse_of: :client_channels
  has_many :campaign_channels, inverse_of: :client_channel
  has_many :datasets, inverse_of: :client_channel, dependent: :destroy

  # Validations
  validates :uid, presence: true
  before_destroy :generating_dataset?

  # Methods
  def nice_name
    self.class.name.demodulize
  end

  private

  def generating_dataset?
    # If there is a dataset that is in the process of generating
    # don't let the client channel get deleted
    puts "Checking if any datasets are currently generating for #{self.nice_name}"
    if datasets.where(status: 'generating').any?
      puts datasets.where(status: 'generating')
      errors.add(:base, "You can't delete this client channel while it is generating a report")
      return false
    end
  end
end
