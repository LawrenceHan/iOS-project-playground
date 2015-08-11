class AddIbnInfosToMedications < ActiveRecord::Migration
  def change
    add_column :medications, :ibn_id, :integer
    add_column :medications, :ibn_name, :string
    add_column :medications, :ibn_code, :string
    add_column :medications, :eph_id, :integer
    add_column :medications, :eph_name, :string
  end
end
