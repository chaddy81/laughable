class AddProfilePictureAttributeToComedian < ActiveRecord::Migration
  def change
    add_column :comedians, :profile_picture, :string
  end
end
