require 'rails_helper'

describe AdminPanel::PhysiciansController, type: :request do

  def login(user)
    post '/admin_panel/login', :email => user.email, :password => 'password'
  end

  before do
    @hospital = create :hospital, name: 'St-Jude'
    @physician = create :physician, hospital: @hospital
    @admin = create :admin,
        password: 'password',
        email: 'bot@thecarevoice.com',
        password_confirmation: 'password'
    login(@admin)
  end

  it 'shows editable profile for male physician' do
    @physician.gender = 'male'
    @physician.save
    get '/admin_panel/physicians/' + @physician.id.to_s + '/edit'
    expect(response.body).to match(/option selected="selected" value="male"/)
    expect(response.body).to match(/Female/)
    expect(response.body).to match(/Male/)
    expect(response.body).to match(/Unknown/)
  end

  it 'shows editable profile for female physician' do
    @physician.gender = 'female'
    @physician.save
    get '/admin_panel/physicians/' + @physician.id.to_s + '/edit'
    expect(response.body).to match(/option selected="selected" value="female"/)

  end

  it 'shows editable profile for physician with unknown gender' do
    @physician.gender = 'unknown'
    @physician.save
    get '/admin_panel/physicians/' + @physician.id.to_s + '/edit'
    expect(response.body).to match(/option selected="selected" value="unknown"/)
  end
end