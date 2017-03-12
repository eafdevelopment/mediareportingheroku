class AddJobIdToDataset < ActiveRecord::Migration[5.0]
  def change
    add_column :datasets, :job_id, :string
  end
end
