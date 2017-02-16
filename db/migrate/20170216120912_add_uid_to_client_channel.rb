class AddUidToClientChannel < ActiveRecord::Migration[5.0]
  def change
    add_column :client_channels, :uid, :string
  end
end
