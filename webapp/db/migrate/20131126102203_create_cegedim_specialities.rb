class CreateCegedimSpecialities < ActiveRecord::Migration
  def change
    create_table :cegedim_specialities do |t|
      t.string :name

      t.timestamps
    end
  end
end
