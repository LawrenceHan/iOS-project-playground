class CreateHospitals < ActiveRecord::Migration
  def change
    create_table :hospitals do |t|
      t.integer :vendor_id
      t.string :name
      t.string :official_name
      t.string :phone
      t.string :address
      t.string :post_code
      t.string :h_class
      t.integer :avg_waiting_time
      t.float :avg_rating, default: 0.0

      t.timestamps
    end

    add_index :hospitals, :vendor_id
    add_index :hospitals, :avg_rating
  end
end
