class AddStreamUrlToTrack < ActiveRecord::Migration
  def change
    add_column :tracks, :stream_url, :string
  end
end
