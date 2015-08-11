class AddNoteToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :note, :text

    Survey::Survey.add_translation_fields! description: :string
    Survey::Survey.add_translation_fields! note: :text
  end
end
