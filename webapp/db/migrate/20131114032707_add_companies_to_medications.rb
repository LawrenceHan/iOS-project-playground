class AddCompaniesToMedications < ActiveRecord::Migration
  def change
    add_column :medications, :companies, :string, array: true, default: []
  end
end
