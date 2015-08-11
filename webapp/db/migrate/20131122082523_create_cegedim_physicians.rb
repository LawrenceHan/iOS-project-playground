class CreateCegedimPhysicians < ActiveRecord::Migration
  def change
    create_table :cegedim_physicians do |t|
      t.string :uid
      t.string :department_uid
      t.string :hospital_uid
      t.string :name
      t.string :position
      t.string :gender
      t.date   :birthdate
      t.string :status
      t.timestamps
    end
  end
end
