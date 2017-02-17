class RemoveColumnFacebookIdFromCampaign < ActiveRecord::Migration[5.0]
  def change
    remove_column :campaigns, :facebook_campaign_id
  end
end
