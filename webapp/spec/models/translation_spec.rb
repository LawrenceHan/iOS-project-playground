require 'rails_helper'

RSpec.describe Translation do
  describe 'sample translations' do
    it 'can look up translation' do
      t1 = Translation.create entity_id: 1, content: 'St-Michael', language: :en
      t1.save
      t = Translation.find_by!(entity_id: 1, language: :en)
      expect(t.content).to eq('St-Michael')
    end
  end
end
