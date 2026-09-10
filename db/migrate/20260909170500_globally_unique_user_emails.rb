class GloballyUniqueUserEmails < ActiveRecord::Migration[8.1]
  def change
    remove_index :users, [:school_id, :email_address], unique: true
    add_index    :users, :email_address, unique: true
  end
end
