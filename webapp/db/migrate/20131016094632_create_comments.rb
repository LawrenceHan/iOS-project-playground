class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :writer_id
      t.belongs_to :user, index: true
      t.text :content
      t.string :status, default: 'pending'

      t.timestamps
    end

    add_index :comments, :writer_id
  end
end
