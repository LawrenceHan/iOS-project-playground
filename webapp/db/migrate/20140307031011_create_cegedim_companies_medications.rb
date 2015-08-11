class CreateCegedimCompaniesMedications < ActiveRecord::Migration
  def change
    create_table :cegedim_companies_medications do |t|
      t.integer :company_uid
      t.integer :medication_uid
      t.date :begin_at
      t.date :end_at

      t.timestamps
    end

    add_index :cegedim_companies_medications, :company_uid
    add_index :cegedim_companies_medications, :medication_uid
  end
end
