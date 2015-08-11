class CreateCegedimMedications < ActiveRecord::Migration
  def change
    create_table :cegedim_medications do |t|
      t.integer :uid
      t.integer :master_uid
      t.string :companies, array: true, default: []
      t.string :code
      t.string :en_name
      t.string :cn_name
      t.integer :otc
      t.string :dosage1
      t.string :dosage2
      t.string :dosage3

      t.timestamps
    end
  end
end
