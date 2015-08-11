class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :txid
      t.references :user, index: true

      t.timestamps
    end
  end
end
