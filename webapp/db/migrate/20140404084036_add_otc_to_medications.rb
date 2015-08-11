class AddOtcToMedications < ActiveRecord::Migration
  def change
    add_column :medications, :otc, :integer
  end
end
