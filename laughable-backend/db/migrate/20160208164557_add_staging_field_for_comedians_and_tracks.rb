class AddStagingFieldForComediansAndTracks < ActiveRecord::Migration
  def change
    add_column :comedians, :staging_only, :boolean, default: false
    add_column :tracks, :staging_only, :boolean, default: false
    add_column :podcasts, :staging_only, :boolean, default: false
    add_column :podcastepisodes, :staging_only, :boolean, default: false
  end
end
