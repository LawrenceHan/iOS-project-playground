class CreateHelpfuls < ActiveRecord::Migration
  def change
    create_table :helpfuls do |t|
      t.belongs_to :review, index: true
      t.belongs_to :user, index: true

      t.datetime :created_at
    end
  end
end
