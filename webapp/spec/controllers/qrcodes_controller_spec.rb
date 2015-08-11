require 'rails_helper'

RSpec.describe QrcodesController, type: :controller do
  describe 'GET show' do
    let(:qrcode) { create :qrcode, url: 'http://google.com' }

    it 'increments count' do
      expect {
        get :show, id: qrcode.id
      }.to change { qrcode.reload.count }.by(1)
      expect(response).to redirect_to('http://google.com')
    end
  end
end
