class RenameCampaignChannelGoogleAnalyticsViewIdToGoogleAnalyticsCampaignName < ActiveRecord::Migration[5.0]
  def change
    rename_column :campaign_channels, :google_analytics_view_id, :google_analytcs_campaign_name
  end
end
