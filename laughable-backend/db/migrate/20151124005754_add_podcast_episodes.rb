class AddPodcastEpisodes < ActiveRecord::Migration
  def change
    add_column :podcasts, :rss_url, :text

    create_table :podcastepisodes do |t|
      t.string :title
      t.integer :guests, array: true, default: []
      t.text :stream_url
      t.text :description
      t.integer :duration
      t.boolean :explicit
      t.integer :podcast_id
      t.text :image_url
      t.text :website
    end
  end
end
