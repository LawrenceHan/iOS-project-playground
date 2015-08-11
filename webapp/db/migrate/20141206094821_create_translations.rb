class CreateTranslations < ActiveRecord::Migration
  def change
    create_table :translations do |t|
      t.integer :entity_id
      t.text :string
      t.string :entity_type
      t.string :field_name
      t.string :language
      t.timestamps
    end
  end
end