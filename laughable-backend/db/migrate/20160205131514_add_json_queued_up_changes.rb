class AddJsonQueuedUpChanges < ActiveRecord::Migration
  def change
    create_table :changes do |t|
      t.json 'attributes'
      t.text 'type'
    end
  end
end
