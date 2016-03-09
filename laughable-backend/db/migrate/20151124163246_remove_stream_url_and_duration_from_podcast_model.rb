class RemoveStreamUrlAndDurationFromPodcastModel < ActiveRecord::Migration
  def change
    remove_column :podcasts, :stream_url, :text
    remove_column :podcasts, :duration, :integer
  end
end
