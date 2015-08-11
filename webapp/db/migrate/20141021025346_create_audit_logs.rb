class CreateAuditLogs < ActiveRecord::Migration
  def change
    create_table :audit_logs do |t|
      t.string :action
      t.integer :record_id
      t.string :record_type
      t.json :record_attributes
      t.json :record_before_attributes
      t.json :record_changes

      t.integer :user_id

      t.timestamps
    end

    add_index :audit_logs, :record_id
    add_index :audit_logs, :record_type
    add_index :audit_logs, :user_id
  end
end
