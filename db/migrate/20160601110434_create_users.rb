class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.integer :role
      t.string :password_digest
      t.string :auth_code
      t.references :sales_manager, index: true
      t.references :country_manager, index: true
      t.string :slug

      t.timestamps null: false
    end
  end
end
