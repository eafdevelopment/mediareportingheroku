class AddClientIdToClientChannel < ActiveRecord::Migration[5.0]
  def change
    add_column :client_channels, :client_id, :integer
  end
end
