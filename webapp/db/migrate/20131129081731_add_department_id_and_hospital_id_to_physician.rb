class AddDepartmentIdAndHospitalIdToPhysician < ActiveRecord::Migration
  def change
    add_reference :physicians, :department, index: true
    add_reference :physicians, :hospital, index: true
  end
end
