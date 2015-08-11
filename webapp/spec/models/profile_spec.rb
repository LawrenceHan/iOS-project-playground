require 'spec_helper'

RSpec.describe Profile, type: :model do
  describe '#set_locale' do
    let(:user) { create(:user) }

    it 'sets locale to zh-CN' do
      I18n.locale = 'zh-CN'
      profile = create :profile, user: user
      expect(profile.reload.locale).to eq 'zh-CN'
    end

    it 'sets locale to en-US' do
      I18n.locale = 'en-US'
      profile = create :profile, user: user
      expect(profile.reload.locale).to eq 'en-US'
    end
  end
end
