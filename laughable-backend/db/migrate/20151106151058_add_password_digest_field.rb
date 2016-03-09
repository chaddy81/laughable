class AddPasswordDigestField < ActiveRecord::Migration
  def change
    add_column :users, :password_digest, :string
    remove_column :users, :password, :integer
  end
end
