class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.belongs_to :user, index: true
      t.references :reportable, polymorphic: true
      t.text :content

      t.timestamps
    end
  end
end
