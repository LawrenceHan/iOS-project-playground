class CreateCardinalHealths < ActiveRecord::Migration
  def change
    create_table :cardinal_healths do |t|
      t.integer :code
      t.integer :baiji_shop_id
      t.string :common_name
      t.string :official_name
      t.string :drug_format
      t.string :size
      t.string :approval_number
      t.string :department_name
      t.string :drug_type
      t.float :member_price
      t.string :company
      t.string :composition
      t.text :usage
      t.text :warning
      t.string :storage_type
      t.string :link
      t.string :picture
      t.string :rx_otc
      t.float :sale_price
      t.string :indications
      t.text :adverse_reactions

      t.timestamps
    end
  end
end
