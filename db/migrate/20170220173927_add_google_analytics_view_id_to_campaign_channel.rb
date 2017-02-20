class AddGoogleAnalyticsViewIdToCampaignChannel < ActiveRecord::Migration[5.0]
  def change
    add_column :campaign_channels, :google_analytics_view_id, :string
  end
end
