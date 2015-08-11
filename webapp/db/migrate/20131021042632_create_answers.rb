class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.belongs_to :review, index: true
      t.belongs_to :question, index: true
      t.integer :waiting_time
      t.integer :rating, default: 0

      t.timestamps
    end
  end
end
