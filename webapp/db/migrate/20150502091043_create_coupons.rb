class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :source
      t.string :code
      t.boolean :used, default: false, null: false
      t.references :user, index: true
      t.references :created_by, polymorphic: true

      t.timestamps
    end
  end
end
