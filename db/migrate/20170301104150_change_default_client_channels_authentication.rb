class ChangeDefaultClientChannelsAuthentication < ActiveRecord::Migration[5.0]
  def change
    change_column :client_channels, :authentication, :jsonb, default: {}
  end
end
