class AddContentManagementSystemJsonField < ActiveRecord::Migration
  def change
    create_table :cmscontents do |t|
      t.json 'entry'
    end
  end
end
