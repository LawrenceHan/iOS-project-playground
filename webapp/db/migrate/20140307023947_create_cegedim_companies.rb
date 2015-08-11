class CreateCegedimCompanies < ActiveRecord::Migration
  def change
    create_table :cegedim_companies do |t|
      t.integer :uid
      t.string :en_name
      t.string :cn_name

      t.timestamps
    end

    add_index :cegedim_companies, :uid
  end
end
