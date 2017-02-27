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

  # Public: Fetch metrics for the client channel. Subclasses of ClientChannel
  # should implement this!
  #
  # Parameters:
  #
  #   from_date - Start date for metrics
  #
  #   to_date - End date for metrics (inclusive)
  #
  #   uid - UID of 'thing' (probably a campaign) being fetched.
  #
  #   ga_campaign_name - The campaign in Google Analytics that correspond to 
  #                      the requested campaign.
  #
  #   optional - Hash of extra parameters including:
  #      
  #      summary_metrics: Array of summary metrics desired, instead
  #      of standard day-by-day metrics.
  #
  # Returns: A hash of:
  #   
  #   header_row: <...>
  #   data_rows: <...>
  #   summary_row: <...>
  #
  def fetch_metrics(from_date, to_date, uid, ga_campaign_name, optional={})
    raise "Subclass should implement #fetch_metrics!"
  end

end
