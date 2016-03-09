class AddJsonEventTracking < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.json 'payload'
    end
  end
end
