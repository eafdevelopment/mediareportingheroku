class ChangeClientChannelToClientChannelId < ActiveRecord::Migration[5.0]
  def change
    rename_column :datasets, :client_channel, :client_channel_id
  end
end
