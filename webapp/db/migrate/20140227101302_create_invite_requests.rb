class CreateInviteRequests < ActiveRecord::Migration
  def change
    create_table :invite_requests do |t|
      t.references :user, index: true
      t.string :emails, array: true, default: []

      t.timestamps
    end
  end
end
