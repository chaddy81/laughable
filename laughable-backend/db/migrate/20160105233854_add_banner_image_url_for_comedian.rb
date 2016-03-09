class AddBannerImageUrlForComedian < ActiveRecord::Migration
  def change
    add_column :comedians, :banner_url, :text
  end
end
