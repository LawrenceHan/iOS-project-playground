class CreateCompaniesMedications < ActiveRecord::Migration
  def change
    create_table :companies_medications do |t|
      t.references :company, index: true
      t.references :medication, index: true
      t.date :begin_at
      t.date :end_at

      t.timestamps
    end


  end
end
