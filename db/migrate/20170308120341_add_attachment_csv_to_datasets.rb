class AddAttachmentCsvToDatasets < ActiveRecord::Migration
  def self.up
    change_table :datasets do |t|
      t.attachment :csv
    end
  end

  def self.down
    remove_attachment :datasets, :csv
  end
end
