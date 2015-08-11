class RemoveIsOptionalFromQuestions < ActiveRecord::Migration
  def change
    remove_column :questions, :is_optional
  end
end
