class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :group
      t.string  :cat_name
      t.string  :title
      t.string  :content
      t.integer :status, :default => 0
      t.string  :image_url
      t.string  :up
      t.string  :down
      t.string  :creator_id
      t.string  :result
      t.integer :number
      t.integer :type

      t.timestamps null: false
    end
  end
end
