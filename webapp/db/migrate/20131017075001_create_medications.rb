class CreateMedications < ActiveRecord::Migration
  def change
    create_table :medications do |t|
      t.integer :vendor_id
      t.string :name
      t.string :code
      t.float :avg_rating, default: 0.0

      t.timestamps
    end

    add_index :medications, :vendor_id
    add_index :medications, :name
  end
end
