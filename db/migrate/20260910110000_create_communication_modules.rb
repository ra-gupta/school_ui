class CreateCommunicationModules < ActiveRecord::Migration[8.1]
  def change
    create_table :message_templates do |t|
      t.references :school, null: false, foreign_key: true
      t.string  :name, null: false
      t.string  :channel, default: "sms", null: false     # sms email whatsapp push
      t.string  :subject
      t.text    :body, null: false
      t.boolean :active, default: true, null: false
      t.timestamps
    end

    create_table :message_logs do |t|
      t.references :school, null: false, foreign_key: true
      t.references :message_template, foreign_key: true
      t.references :sent_by, foreign_key: { to_table: :users }
      t.string   :channel, default: "sms", null: false
      t.string   :audience, default: "all", null: false
      t.string   :recipient
      t.string   :subject
      t.text     :body, null: false
      t.string   :status, default: "queued", null: false  # queued sent failed
      t.integer  :recipient_count, default: 1, null: false
      t.datetime :sent_at
      t.string   :error
      t.timestamps
      t.index [ :school_id, :sent_at ]
    end

    create_table :ptm_meetings do |t|
      t.references :school, null: false, foreign_key: true
      t.references :section, foreign_key: true
      t.string  :title, null: false
      t.date    :on_date, null: false
      t.time    :starts_at
      t.time    :ends_at
      t.integer :slot_minutes, default: 15, null: false
      t.string  :venue
      t.string  :status, default: "scheduled", null: false
      t.timestamps
      t.index [ :school_id, :on_date ]
    end

    create_table :ptm_slots do |t|
      t.references :school, null: false, foreign_key: true
      t.references :ptm_meeting, null: false, foreign_key: true
      t.references :staff, foreign_key: true
      t.references :student, foreign_key: true
      t.time    :starts_at, null: false
      t.string  :status, default: "open", null: false     # open booked attended missed
      t.text    :remarks
      t.timestamps
      t.index [ :ptm_meeting_id, :staff_id, :starts_at ], name: "idx_ptm_slot_unique"
    end

    create_table :surveys do |t|
      t.references :school, null: false, foreign_key: true
      t.string  :title, null: false
      t.text    :description
      t.string  :audience, default: "parents", null: false
      t.date    :opens_on
      t.date    :closes_on
      t.boolean :anonymous, default: false, null: false
      t.string  :status, default: "draft", null: false
      t.timestamps
    end

    create_table :survey_questions do |t|
      t.references :school, null: false, foreign_key: true
      t.references :survey, null: false, foreign_key: true
      t.string  :prompt, null: false
      t.string  :kind, default: "rating", null: false     # rating choice text
      t.string  :choices, array: true, default: [], null: false
      t.integer :position, default: 0, null: false
      t.boolean :required, default: true, null: false
      t.timestamps
    end

    create_table :survey_responses do |t|
      t.references :school, null: false, foreign_key: true
      t.references :survey_question, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :rating
      t.string  :choice
      t.text    :answer
      t.timestamps
      t.index [ :survey_question_id, :user_id ]
    end

    create_table :kb_articles do |t|
      t.references :school, null: false, foreign_key: true
      t.string  :title, null: false
      t.string  :category
      t.text    :body, null: false
      t.string  :audience, default: "all", null: false
      t.boolean :published, default: true, null: false
      t.integer :views, default: 0, null: false
      t.timestamps
      t.index [ :school_id, :category ]
    end

    create_table :web_pages do |t|
      t.references :school, null: false, foreign_key: true
      t.string  :title, null: false
      t.string  :slug, null: false
      t.text    :body
      t.string  :section, default: "page", null: false    # page news gallery
      t.integer :position, default: 0, null: false
      t.boolean :published, default: false, null: false
      t.timestamps
      t.index [ :school_id, :slug ], unique: true
    end

    create_table :greeting_campaigns do |t|
      t.references :school, null: false, foreign_key: true
      t.string  :title, null: false
      t.string  :occasion, default: "birthday", null: false
      t.string  :audience, default: "students", null: false
      t.text    :message
      t.string  :background_color, default: "#4f46e5", null: false
      t.boolean :automatic, default: true, null: false
      t.timestamps
    end

    create_table :conversations do |t|
      t.references :school, null: false, foreign_key: true
      t.references :student, foreign_key: true
      t.references :staff, null: false, foreign_key: true
      t.references :guardian, foreign_key: true
      t.string   :subject
      t.datetime :last_message_at
      t.timestamps
      t.index [ :school_id, :last_message_at ]
    end

    create_table :chat_messages do |t|
      t.references :school, null: false, foreign_key: true
      t.references :conversation, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.text     :body, null: false
      t.datetime :read_at
      t.timestamps
      t.index [ :conversation_id, :created_at ]
    end
  end
end
