class FixGoogleAnalyticsCampaignNameTypo < ActiveRecord::Migration[5.0]
  def change
    rename_column :campaign_channels, :google_analytcs_campaign_name, :google_analytics_campaign_name
  end
end
