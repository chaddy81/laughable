class RenameTypeInTrack < ActiveRecord::Migration
  def change
    rename_column :tracks, :type, :track_type
  end
end
