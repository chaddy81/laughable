class CreateComedians < ActiveRecord::Migration
  def change
    create_table :comedians do |t|
      t.string :name
      t.text :biography
      t.text :website
      t.string :twitter_name
      t.string :facebook_name
      t.string :instagram_name

      t.timestamps null: false
    end
  end
end
