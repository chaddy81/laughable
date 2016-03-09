class AddPodcasterModel < ActiveRecord::Migration
  def change
    create_table :podcasters do |t|
      t.string :artist
      t.text :biography
      t.text :website
      t.text :rss_url
    end
  end
end
