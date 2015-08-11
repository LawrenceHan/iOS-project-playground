class AddColorToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :color, :string
  end
end
