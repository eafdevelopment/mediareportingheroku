class CreateClientChannels < ActiveRecord::Migration[5.0]
  def change
    create_table :client_channels do |t|
      t.string :type

      t.timestamps
    end
  end
end
