class RemoveFacebookAccountIdFromClient < ActiveRecord::Migration[5.0]
  def change
    remove_column :clients, :facebook_account_id
  end
end
