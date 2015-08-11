class CreatePhysicians < ActiveRecord::Migration
  def change
    create_table :physicians do |t|
      t.integer :vendor_id
      t.string :name
      t.string :position
      t.integer :speciality_ids, array: true
      t.float :avg_rating, default: 0.0

      t.timestamps
    end

    add_index :physicians, :vendor_id
    add_index :physicians, :name
    add_index :physicians, :speciality_ids
  end
end
