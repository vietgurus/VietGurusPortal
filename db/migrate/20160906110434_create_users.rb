class CreateUsers < ActiveRecord::Migration
  if table_exists?("users")
    drop_table  :users
  end
  def change
    create_table :users do |t|
      t.string :name
      t.string :password
      t.string :password_digest
      t.string :email
      t.integer :role
    end
  end
end
