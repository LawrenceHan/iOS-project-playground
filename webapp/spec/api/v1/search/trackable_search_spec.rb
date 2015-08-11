module V1::Search
  describe ReviewSearch::API do
    let(:user) { create :user }
    before { login_as user }

    describe 'GET /v1/search/reviews/by_type and check trackable logs' do
      it 'gets reviews by hospital and check trackable logs' do
        get '/v1/search/reviews/by_type?type=hospital'
        t = TrackableLog.all.last
        expect(t.log['REQUEST_URI']).to eq('/v1/search/reviews/by_type?type=hospital')
        expect(t.log['status']).to eq(200)
      end
    end
  end
end
