class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :owner_email
      t.string :guest_email

      t.datetime :created_at
    end

    add_index :invitations, :owner_email
    add_index :invitations, :guest_email
  end
end
