class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.belongs_to :medical_experience, index: true
      t.integer :reviewable_id
      t.string  :type
      t.integer :helpfuls_count, default: 0
      t.string :dosage
      t.string :intake_frequency
      t.string :duration
      t.string :adverse_effects
      t.float :completion, default: 0.0
      t.float :avg_rating, default: 0.0
      t.text :note
      t.string :status, default: 'pending'

      t.timestamps
    end

    add_index :reviews, :reviewable_id
    add_index :reviews, :type
  end
end
