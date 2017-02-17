class AddFacebookAccountIdToClient < ActiveRecord::Migration[5.0]
  def change
    add_column :clients, :facebook_account_id, :string
  end
end
