class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string  :cat_name
      t.string  :title
      t.string  :content
      t.string  :image_url
      t.string  :up
      t.string  :down
      t.string  :creator_id
      t.string  :result
      t.integer :type
    end
  end
end
