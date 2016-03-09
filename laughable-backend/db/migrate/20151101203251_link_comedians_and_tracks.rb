class LinkComediansAndTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :comedian_id, :integer
    add_foreign_key :tracks, :comedians
  end
end
