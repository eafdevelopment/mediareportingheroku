class CreateCampaignChannels < ActiveRecord::Migration[5.0]
  def change
    create_table :campaign_channels do |t|
      t.string :uid

      t.timestamps
    end
  end
end
