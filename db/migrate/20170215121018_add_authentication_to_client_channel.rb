class AddAuthenticationToClientChannel < ActiveRecord::Migration[5.0]
  def change
    add_column :client_channels, :authentication, :json, null: false, default: '{}'
  end
end
