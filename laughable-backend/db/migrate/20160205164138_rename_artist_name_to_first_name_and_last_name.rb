class RenameArtistNameToFirstNameAndLastName < ActiveRecord::Migration
  def change
    rename_column :comedians, :name, :last_name
    add_column :comedians, :first_name, :string
    add_column :comedians, :middle_name, :string
  end
end
