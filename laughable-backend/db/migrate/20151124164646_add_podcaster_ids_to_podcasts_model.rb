class AddPodcasterIdsToPodcastsModel < ActiveRecord::Migration
  def change
    remove_column :podcasts, :podcaster_id
    add_column :podcasts, :podcaster_ids, :integer, array: true, default: []
  end
end
