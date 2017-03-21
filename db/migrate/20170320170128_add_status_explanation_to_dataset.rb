class AddStatusExplanationToDataset < ActiveRecord::Migration[5.0]
  def change
    add_column :datasets, :status_explanation, :string
  end
end
