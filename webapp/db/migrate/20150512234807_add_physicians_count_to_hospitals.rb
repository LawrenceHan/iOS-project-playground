class AddPhysiciansCountToHospitals < ActiveRecord::Migration
  def change
    add_column :hospitals, :physicians_count, :integer

    Hospital.find_each do |hospital|
      Hospital.reset_counters(hospital.id, :physicians)
    end
  end
end
