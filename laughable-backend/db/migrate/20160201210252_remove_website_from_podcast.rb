class RemoveWebsiteFromPodcast < ActiveRecord::Migration
  def change
    remove_column :podcasts, :website, :text
  end
end
