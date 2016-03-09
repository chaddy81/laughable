class AddInactiveComedianId < ActiveRecord::Migration
  def change
    add_column :comedians, :inactive, :boolean, default: true
  end
end
