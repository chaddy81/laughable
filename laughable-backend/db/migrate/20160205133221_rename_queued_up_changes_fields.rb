class RenameQueuedUpChangesFields < ActiveRecord::Migration
  def change
    rename_column :changes, :type, :data_type
    rename_column :changes, :attributes, :values
  end
end
