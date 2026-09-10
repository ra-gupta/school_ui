class AllowLoginByPhone < ActiveRecord::Migration[8.1]
  def up
    # A phone number is about to become a login identity, so it has to identify
    # exactly one account. Anything already duplicated is cleared rather than
    # guessed at — the older account keeps the number.
    execute <<~SQL
      UPDATE users SET phone = NULL
      WHERE phone IS NOT NULL
        AND id NOT IN (SELECT MIN(id) FROM users WHERE phone IS NOT NULL GROUP BY phone)
    SQL

    add_index :users, :phone, unique: true, where: "phone IS NOT NULL"
  end

  def down
    remove_index :users, :phone
  end
end
