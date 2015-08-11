module V1::Reviews
  describe Answers::API do
    let(:user) { create :user }
    before { login_as user }

    describe 'POST /v1/reviews/answers' do
      it 'creates an answer' do
        expect {
          post '/v1/reviews/answers', answer: {review_id: 1, question_id: 1, waiting_time: 1, rating: 1}
        }.to change { Answer.count }.by(1)
        expect(response.status).to eq 201
      end

      it 'fails to create an answer' do
        expect {
          post '/v1/reviews/answers', answer: {review_id: 1, question_id: 1, waiting_time: -1, rating: 1}
        }.not_to change { Answer.count }
        expect(response.status).to eq 422
      end
    end
  end
end
