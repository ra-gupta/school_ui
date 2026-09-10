class CreateCore < ActiveRecord::Migration[8.1]
  def change
    create_table :schools do |t|
      t.string  :name, null: false
      t.string  :code, null: false
      t.string  :subdomain, null: false
      t.string  :email
      t.string  :phone
      t.string  :website
      t.text    :address
      t.string  :city
      t.string  :state
      t.string  :country, default: "IN"
      t.string  :postcode
      t.string  :timezone, default: "Asia/Kolkata", null: false
      t.string  :currency, default: "INR", null: false
      t.string  :locale, default: "en", null: false
      t.string  :theme, default: "default", null: false
      t.string  :primary_color, default: "#4f46e5", null: false
      t.string  :enabled_modules, array: true, default: [], null: false
      t.jsonb   :settings, default: {}, null: false
      t.boolean :active, default: true, null: false
      t.date    :subscription_ends_on
      t.timestamps
      t.index :code, unique: true
      t.index :subdomain, unique: true
    end

    create_table :academic_years do |t|
      t.references :school, null: false, foreign_key: true
      t.string  :name, null: false
      t.date    :starts_on, null: false
      t.date    :ends_on, null: false
      t.boolean :current, default: false, null: false
      t.timestamps
      t.index [ :school_id, :name ], unique: true
    end

    create_table :roles do |t|
      t.references :school, foreign_key: true
      t.string :name, null: false
      t.string :permissions, array: true, default: [], null: false
      t.boolean :system, default: false, null: false
      t.timestamps
      t.index [ :school_id, :name ], unique: true
    end
  end
end
