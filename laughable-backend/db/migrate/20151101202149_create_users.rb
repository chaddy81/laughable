class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :email
      t.text :password
      t.boolean :admin, default: false
      t.boolean :fake_user, default: false
      t.integer :phone_number

      t.timestamps null: false
    end
  end
end
