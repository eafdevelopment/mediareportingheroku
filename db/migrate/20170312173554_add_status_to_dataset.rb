class AddStatusToDataset < ActiveRecord::Migration[5.0]
  def change
    add_column :datasets, :status, :string
  end
end
