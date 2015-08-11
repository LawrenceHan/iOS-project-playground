require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#microsites_url' do
    let(:physician) { create :physician }
    it 'generates url for physician' do
      expect(microsites_url(physician)).to eq "/microsites/physician.html?vendor_id=#{physician.vendor_id}"
    end
  end
end
