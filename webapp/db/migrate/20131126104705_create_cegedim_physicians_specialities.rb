class CreateCegedimPhysiciansSpecialities < ActiveRecord::Migration
  def change
    create_table :cegedim_physicians_specialities do |t|
      t.string :physician_uid
      t.integer :speciality_id
      t.integer :priority, default: 1
      t.timestamps
    end
  end
end
