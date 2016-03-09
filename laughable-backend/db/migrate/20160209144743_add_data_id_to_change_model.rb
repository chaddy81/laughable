class AddDataIdToChangeModel < ActiveRecord::Migration
  def change
    add_column :changes, :data_id, :integer
  end
end
