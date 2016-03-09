class AddPublishDateToPodcastInformation < ActiveRecord::Migration
  def change
    add_column :podcastepisodes, :publish_date, :integer
  end
end
