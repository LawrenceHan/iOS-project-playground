require 'rails_helper'

describe Mobile::PhysiciansController, type: :request do
  before do
    @hospital = create :hospital, name: 'St-Jude'
    @physician_male = create :physician, gender: 'male', hospital: @hospital
    @physician_female = create :physician, gender: 'female', hospital: @hospital
    @physician_unknown = create :physician, hospital: @hospital
  end

  it 'shows profile correctly for male physician' do
    get '/mobile/physicians/' + @physician_male.id.to_s
    expect(response.status).to eq(200)
    expect(response.body).to match(/男/)
  end

  it 'shows profile correctly for female physician' do
    get '/mobile/physicians/' + @physician_female.id.to_s
    expect(response.status).to eq(200)
    expect(response.body).to match(/女/)
  end

  it 'shows profile correctly for unknown physician' do
    get '/mobile/physicians/' + @physician_unknown.id.to_s
    expect(response.status).to eq(200)
    expect(response.body).to_not match(/男/)
    expect(response.body).to_not match(/女/)
  end
end