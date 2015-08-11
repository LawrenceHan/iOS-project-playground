class AddLogoToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :logo, :string
  end
end
