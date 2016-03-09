class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.string :title
      t.string :author
      t.text :description
      t.integer :duration
      t.string :type

      t.timestamps null: false
    end
  end
end
