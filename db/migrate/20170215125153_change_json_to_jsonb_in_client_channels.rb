class ChangeJsonToJsonbInClientChannels < ActiveRecord::Migration[5.0]
  def up
    change_column :client_channels, :authentication, :jsonb
  end
  def down
    change_column :client_channels, :authentication, :json
  end
end
