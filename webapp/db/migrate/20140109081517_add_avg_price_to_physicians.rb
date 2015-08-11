class AddAvgPriceToPhysicians < ActiveRecord::Migration
  def change
    add_column :physicians, :avg_price, :integer, default: 0
    add_column :answers, :price, :integer, default: 0
  end
end
