class AddSubscriptionsToComedianAndPodcasterByUser < ActiveRecord::Migration
  def change
    create_table :comedian_subscriptions do |t|
      t.integer :user_id
      t.integer :comedian_id
      t.datetime :subscription_date
      t.boolean :active
    end

    create_table :podcast_subscriptions do |t|
      t.integer :user_id
      t.integer :comedian_id
      t.datetime :subscription_date
      t.boolean :active
    end
  end
end
