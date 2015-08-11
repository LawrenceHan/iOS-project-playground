class CreatePhysiciansSpecialities < ActiveRecord::Migration
  def change
    create_table :physicians_specialities do |t|
      t.belongs_to :physician, index: true
      t.belongs_to :speciality, index: true

      t.timestamps
    end
  end
end
