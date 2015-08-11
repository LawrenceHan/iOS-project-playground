class AddCategoryToConditionsAndSymptoms < ActiveRecord::Migration
  def change
    add_column :conditions, :category, :string
    add_column :symptoms, :category, :string
  end
end
