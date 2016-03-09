class AddComedianIdToTrack < ActiveRecord::Migration
  def change
    add_column :tracks, :comedian_id, :integer
  end
end
