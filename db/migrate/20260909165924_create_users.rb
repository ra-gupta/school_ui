class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.references :school, foreign_key: true
      t.string  :email_address, null: false
      t.string  :password_digest, null: false
      t.string  :name, null: false
      t.string  :phone
      t.string  :kind, null: false, default: "staff" # super_admin admin staff teacher parent student driver
      t.boolean :active, default: true, null: false
      t.string  :locale
      t.datetime :last_seen_at
      t.timestamps
      t.index [ :school_id, :email_address ], unique: true
    end

    create_table :role_assignments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.timestamps
      t.index [ :user_id, :role_id ], unique: true
    end
  end
end
