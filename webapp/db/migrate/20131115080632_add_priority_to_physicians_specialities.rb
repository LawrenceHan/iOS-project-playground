class AddPriorityToPhysiciansSpecialities < ActiveRecord::Migration
  def change
    add_column :physicians_specialities, :priority, :integer
    add_index :physicians_specialities, :priority
  end
end
