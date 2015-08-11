class AddPhoneToDepartments < ActiveRecord::Migration
  def change
    add_column :departments, :phone, :string
  end
end
