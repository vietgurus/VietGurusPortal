class AddImageUrlAndAlterImageIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :image_url, :string, null: true
    change_column :users, :image_id, :string, null: true
  end
end
