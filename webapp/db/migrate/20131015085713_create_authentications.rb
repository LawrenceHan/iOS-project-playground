class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.belongs_to :user, index: true
      t.string :provider
      t.string :uid
      t.string :token

      t.timestamps
    end

    add_index :authentications, :provider
    add_index :authentications, :uid
  end
end
