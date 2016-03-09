class RenameGuestsToComedianIDsAndPodcasterIdsToComedianIDs < ActiveRecord::Migration
  def change
    rename_column :podcasts, :podcaster_ids, :comedian_ids
    rename_column :podcastepisodes, :guests, :comedian_ids
  end
end
