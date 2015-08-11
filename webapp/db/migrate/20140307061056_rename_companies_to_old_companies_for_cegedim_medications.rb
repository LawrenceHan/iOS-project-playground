class RenameCompaniesToOldCompaniesForCegedimMedications < ActiveRecord::Migration
  def change
    rename_column :cegedim_medications, :companies, :old_companies
    rename_column :medications, :companies, :old_companies
  end
end
