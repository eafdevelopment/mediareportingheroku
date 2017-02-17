class AddRelationsToCampaignChannel < ActiveRecord::Migration[5.0]
  def change
    add_column :campaign_channels, :campaign_id, :integer
    add_column :campaign_channels, :client_channel_id, :integer
  end
end
