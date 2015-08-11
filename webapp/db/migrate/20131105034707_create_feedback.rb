class CreateFeedback < ActiveRecord::Migration
  def change
    create_table :feedback do |t|
      t.belongs_to :user, index: true
      t.text :content

      t.timestamps
    end
  end
end
