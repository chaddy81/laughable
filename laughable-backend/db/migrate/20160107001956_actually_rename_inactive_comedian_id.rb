class ActuallyRenameInactiveComedianId < ActiveRecord::Migration
  def change
    rename_column :comedians, :inactive, :active
  end
end
