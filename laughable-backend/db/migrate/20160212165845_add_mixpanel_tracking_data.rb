class AddMixpanelTrackingData < ActiveRecord::Migration
  def change
    create_table :mixpanel_events do |t|
      t.string 'distinct_id'
      t.string 'event'
      t.json 'payload'
    end
  end
end
