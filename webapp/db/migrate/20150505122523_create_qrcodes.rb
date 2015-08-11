class CreateQrcodes < ActiveRecord::Migration
  def change
    create_table :qrcodes do |t|
      t.string :title
      t.string :url
      t.string :code
      t.integer :count, default: 0

      t.timestamps
    end
  end
end
