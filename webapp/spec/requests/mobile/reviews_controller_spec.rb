require 'rails_helper'

describe Mobile::ReviewsController, type: :request do
  before do
    @hospital = create :hospital, name: 'St-Jude'
    @physician = create :physician, hospital: @hospital
    @review = create :physician_review, physician: @physician
  end

  it 'shows profile for male physician' do
    @physician.gender = 'male'
    @physician.save
    get '/mobile/reviews/' + @review.id.to_s
    expect(response.status).to eq(200)
    expect(response.body).to match(/男/)
  end

  it 'shows profile for female physician' do
    @physician.gender = 'female'
    @physician.save
    get '/mobile/reviews/' + @review.id.to_s
    expect(response.status).to eq(200)
    expect(response.body).to match(/女/)
  end

  it 'shows profile for physician with unknown gender' do
    get '/mobile/reviews/' + @review.id.to_s
    expect(response.status).to eq(200)
    expect(response.body).to_not match(/男/)
    expect(response.body).to_not match(/女/)
  end
end