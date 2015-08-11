require 'rails_helper'

RSpec.describe Review, type: :model do
  describe '#username' do
    it 'displays anonymous' do
      user = create :user
      review = create :review, user: user
      expect(review.username).to eq I18n.t('anonymous')
    end

    it 'displays customized name' do
      user = create :user, username: 'Richard'
      review = create :review, user: user
      expect(review.username).to eq 'Richard'
    end
  end
end
