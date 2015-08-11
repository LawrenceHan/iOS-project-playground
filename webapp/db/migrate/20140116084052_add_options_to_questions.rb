class AddOptionsToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :options, :json
  end
end
