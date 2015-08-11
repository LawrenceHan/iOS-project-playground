require 'rails_helper'

describe Mobile::SessionsController, type: :request do
  it 'has a GA code' do
    get '/mobile/sign_in'
    expect(response.body).to match(/<\/html>/)
    # testing Google Analytics snippet (development, test, staging)
    expect(response.body).to match(/UA-57980386-2/)
  end
end