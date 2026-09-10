class AddNotifications < ActiveRecord::Migration[8.1]
  def change
    # Channels a person accepts, and events they have muted. Two columns beat a
    # preferences table until someone actually needs per-event channel choice.
    add_column :users, :notification_channels, :string, array: true, default: [ "email" ], null: false
    add_column :users, :muted_events, :string, array: true, default: [], null: false

    # Ties a template to the event it renders, so a school can reword an alert
    # without a deploy.
    add_column :message_templates, :event, :string
    add_index  :message_templates, [ :school_id, :event, :channel ], name: "idx_template_for_event"

    # message_logs already record what was sent; these make a real delivery
    # attempt inspectable rather than just logged.
    add_column :message_logs, :event, :string
    add_column :message_logs, :user_id, :bigint
    add_column :message_logs, :attempts, :integer, default: 0, null: false
    add_column :message_logs, :delivered_at, :datetime
    add_foreign_key :message_logs, :users
    add_index :message_logs, [ :school_id, :event, :created_at ]
    add_index :message_logs, :user_id
  end
end
