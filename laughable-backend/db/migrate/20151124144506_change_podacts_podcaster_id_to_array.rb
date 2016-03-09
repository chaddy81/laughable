class ChangePodactsPodcasterIdToArray < ActiveRecord::Migration
  def change
    change_column :podcasts, :podcaster_id, :integer, aray: true, default: []
  end
end
