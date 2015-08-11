class CreateMedicalExperiences < ActiveRecord::Migration
  def change
    create_table :medical_experiences do |t|
      t.belongs_to :user, index: true
      t.belongs_to :referral_code, index: true
      t.integer :symptom_ids, array: true
      t.integer :condition_ids, array: true
      t.boolean :network_visible, default: true
      t.boolean :behalf
      t.float :completion, default: 0.0
      t.float :avg_rating, default: 0.0

      t.timestamps
    end

    add_index :medical_experiences, :symptom_ids
    add_index :medical_experiences, :condition_ids
  end
end
