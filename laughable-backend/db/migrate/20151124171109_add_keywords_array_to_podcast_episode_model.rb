class AddKeywordsArrayToPodcastEpisodeModel < ActiveRecord::Migration
  def change
    add_column :podcastepisodes, :external_keywords, :text, array: true, default: []
  end
end
