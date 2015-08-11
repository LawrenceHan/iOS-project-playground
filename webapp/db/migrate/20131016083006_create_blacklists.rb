class CreateBlacklists < ActiveRecord::Migration
  def change
    create_table :blacklists do |t|
      t.string :word

      t.timestamps
    end

    add_index :blacklists, :word
  end
end
