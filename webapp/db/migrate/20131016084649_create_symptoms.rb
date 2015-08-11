class CreateSymptoms < ActiveRecord::Migration
  def change
    create_table :symptoms do |t|
      t.string :name

      t.timestamps
    end

    add_index :symptoms, :name
  end
end
