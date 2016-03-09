class AddExternalIdToPodcastEpisodes < ActiveRecord::Migration
  def change
    add_column :podcastepisodes, :external_id, :text
  end
end
