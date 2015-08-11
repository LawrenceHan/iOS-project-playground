class CreateCegedimHospitals < ActiveRecord::Migration
  def change
    create_table :cegedim_hospitals do |t|
      t.string :uid
      t.string :parent_uid
      t.string :name
      t.string :official_name
      t.string :phone
      t.string :address
      t.string :post_code
      t.string :city
      t.string :district
      t.string :h_type
      t.string :h_class
      t.string :status, default: 'open'
      t.timestamps
    end
  end
end
