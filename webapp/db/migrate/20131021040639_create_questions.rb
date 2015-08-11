class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :category
      t.boolean :is_optional
      t.string :content

      t.timestamps
    end

    add_index :questions, :category
    add_index :questions, :is_optional
  end
end
