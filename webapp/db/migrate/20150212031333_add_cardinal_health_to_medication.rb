class AddCardinalHealthToMedication < ActiveRecord::Migration
  def change
    add_reference :cardinal_healths, :medication, index: true
  end
end
