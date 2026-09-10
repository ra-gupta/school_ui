class AddDedupeKeyToMessageLogs < ActiveRecord::Migration[8.1]
  def change
    # Every trigger needs the same guard: tell this person about this thing
    # once. Doing it in the database makes it exact and race-free, instead of
    # each job inventing its own "have I already?" query.
    add_column :message_logs, :dedupe_key, :string
    add_index  :message_logs, [ :school_id, :user_id, :channel, :dedupe_key ],
               unique: true, where: "dedupe_key IS NOT NULL", name: "idx_message_log_once"
  end
end
