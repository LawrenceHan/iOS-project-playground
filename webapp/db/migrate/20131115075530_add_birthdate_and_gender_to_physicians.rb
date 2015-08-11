class AddBirthdateAndGenderToPhysicians < ActiveRecord::Migration
  def change
    add_column :physicians, :birthdate, :date
    add_column :physicians, :gender, :string
  end
end
