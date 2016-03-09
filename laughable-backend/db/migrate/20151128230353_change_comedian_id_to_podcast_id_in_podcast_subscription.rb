class ChangeComedianIdToPodcastIdInPodcastSubscription < ActiveRecord::Migration
  def change
    rename_column :podcast_subscriptions, :comedian_id, :podcast_id
  end
end
