class AddGoogleAnalyticsViewIdToClient < ActiveRecord::Migration[5.0]
  def change
    add_column :clients, :google_analytics_view_id, :string
  end
end
