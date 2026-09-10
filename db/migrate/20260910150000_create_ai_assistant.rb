class CreateAiAssistant < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_conversations do |t|
      t.references :school, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string   :title
      t.datetime :last_message_at
      t.timestamps
      t.index [ :user_id, :last_message_at ]
    end

    create_table :ai_messages do |t|
      t.references :school, null: false, foreign_key: true
      t.references :ai_conversation, null: false, foreign_key: true
      t.string  :role, null: false                 # user | assistant
      t.text    :body, null: false
      t.integer :input_tokens
      t.integer :output_tokens
      t.integer :cached_tokens
      t.string  :model
      t.timestamps
      t.index [ :ai_conversation_id, :created_at ]
    end
  end
end
