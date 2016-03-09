class RemoveColumnFromTracksTable < ActiveRecord::Migration
  def change
    remove_column :tracks, :comedian_id, :integer
  end
end
