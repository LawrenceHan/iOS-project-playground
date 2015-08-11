class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.integer :vendor_id
      t.string :en_name
      t.string :cn_name

      t.timestamps
    end

    add_index :companies, :vendor_id
  end
end
