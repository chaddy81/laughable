class AddArtistsAndPodcasterName < ActiveRecord::Migration
  def change
    remove_column :podcasters, :rss_url, :text
  end
end
