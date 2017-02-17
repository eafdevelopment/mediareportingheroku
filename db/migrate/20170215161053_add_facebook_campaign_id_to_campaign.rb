class AddFacebookCampaignIdToCampaign < ActiveRecord::Migration[5.0]
  def change
    add_column :campaigns, :facebook_campaign_id, :string
  end
end
