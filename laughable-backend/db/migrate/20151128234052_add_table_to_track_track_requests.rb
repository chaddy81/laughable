class AddTableToTrackTrackRequests < ActiveRecord::Migration
  def change
    create_table :track_requests do |t|
      t.integer :track_id
      t.integer :user_id
      t.datetime :requested
    end

    create_table :podcast_episode_requests do |t|
      t.integer :podcast_episode_id
      t.integer :user_id
      t.datetime :requested
    end
  end
end
