class AddComedianIdToPodcasterAndPodcasterIdToComedian < ActiveRecord::Migration
  def change
    add_column :podcasters, :comedian_id, :integer
    add_column :podcasters, :image_url, :text
    add_column :comedians, :podcaster_id, :integer
  end
end
