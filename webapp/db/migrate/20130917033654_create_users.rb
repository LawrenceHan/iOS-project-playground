class CreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      ## Custom columns
      t.string :phone
      t.string :sms_token
      t.datetime :sms_confirmed_at

      ## Database authenticatable
      t.string :email,              :null => false, :default => ""
      t.string :password_digest,    :null => false, :default => ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email

      t.timestamps
    end

    add_index :users, :phone
    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :confirmation_token,   :unique => true
  end
end
