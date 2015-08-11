class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.belongs_to :user, index: true
      t.integer :medical_experiences_count, default: 0
      t.string :username
      t.string :avatar
      t.string :gender
      t.date :birthdate
      t.float :height
      t.float :weight
      t.string :pathway
      t.string :occupation
      t.string :country
      t.string :city
      t.boolean :network_visible
      t.string :income_level
      t.integer :condition_ids, array: true, default: []
      t.string :interests, array: true, default: []
      t.boolean :social_network_visible
      t.json :social_friends
      t.float :completion, default: 0.0

      t.timestamps
    end

    add_index :profiles, :occupation
    add_index :profiles, :country
    add_index :profiles, :city
    add_index :profiles, :income_level
  end
end
