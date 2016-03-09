class AddHighMediumLowQualityTrackStreams < ActiveRecord::Migration
  def change
    rename_column :tracks, :stream_url, :high_stream_url
    add_column :tracks, :medium_stream_url, :string
    add_column :tracks, :low_stream_url, :string
  end
end
