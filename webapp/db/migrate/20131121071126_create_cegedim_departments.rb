class CreateCegedimDepartments < ActiveRecord::Migration
  def change
    create_table :cegedim_departments do |t|
      t.string :uid
      t.string :hospital_uid
      t.string :name
      t.timestamps
    end
  end
end
