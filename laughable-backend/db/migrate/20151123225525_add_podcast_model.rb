class AddPodcastModel < ActiveRecord::Migration
  def change
    create_table :podcasts do |t|
      t.string :title
      t.text :website
      t.text :summary
      t.text :stream_url
      t.integer :duration
      t.text :image_url
      t.integer :podcaster_id
    end
  end
end
