class AddClientIdToCampaign < ActiveRecord::Migration[5.0]
  def change
    add_column :campaigns, :client_id, :intiger
  end
end