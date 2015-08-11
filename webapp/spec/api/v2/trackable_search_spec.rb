require 'rails_helper'

describe V2::Search::API do
  describe 'trackable search' do

    before do
      # TODO: see https://github.com/thecarevoice/webapp/issues/251
      @hospital = create :hospital, name: '上海市儿童医学中心'
    end

    it 'HTTP_USER_AGENT is recorded' do
      post '/v2/search?HTTP_USER_AGENT=AGENT_FROM_QUERY', { query: { type: 'Hospital' } },
        { HTTP_USER_AGENT: 'SuperDuper/1.0'}
      t = TrackableLog.all.last
      expect(t.log['HTTP_USER_AGENT']).to eq('SuperDuper/1.0')
    end

    it 'SERVER_NAME is recorded' do
      host! 'api.kangyu.co'
      post '/v2/search?SERVER_NAME=SERVER_NAME_FROM_QUERY', { query: { type: 'Hospital' } }
      t = TrackableLog.all.last
      expect(t.log['SERVER_NAME']).to eq('api.kangyu.co')
    end

    it 'Query parameters are recorded' do
      post '/v2/search?TOKEN=SOMETHING', { query: { type: 'Hospital' } }
      t = TrackableLog.all.last
      expect(t.log['REQUEST_URI']).to eq('/v2/search?TOKEN=SOMETHING')
    end

    it 'Query parameter with no value' do
      post '/v2/search?TOKEN=', { query: { type: 'Hospital' } }
      t = TrackableLog.all.last
      expect(t.log['REQUEST_URI']).to eq('/v2/search?TOKEN=')
      expect(t.log['params']['TOKEN']).to eq('')
    end

    it 'Discarded information CONTENT_TYPE, QUERY_STRING' do
      post '/v2/search?CONTENT_TYPE=CONTENT_TYPE_FROM_QUERY', { query: { type: 'Hospital' } }
      t = TrackableLog.all.last
      expect(t.log).not_to include('CONTENT_TYPE')
      expect(t.log).not_to include('QUERY_STRING')
      expect(t.log).not_to include('REQUEST_METHOD')
    end

    it 'Optional headers prefixed with X-TCV' do
      headers = {}
      headers['X-TCV-REMOTE_ADDR'] = '23.41.244.226'
      post '/v2/search', { query: { type: 'Hospital' } }, headers
      t = TrackableLog.all.last
      expect(t.log['X-TCV-REMOTE_ADDR']).to eq('23.41.244.226')
    end

    it 'When not logged in, has user_id but is nil' do
      post '/v2/search', { query: { type: 'Hospital' } }
      t = TrackableLog.all.last
      expect(t.log['user_id']).to eq(nil)
    end

    it 'Keep track of user_id' do
      user = create :user
      login_as user
      post '/v2/search', { query: { type: 'Hospital' } }
      t = TrackableLog.all.last
      expect(t.log['user_id']).to eq(user.id)
    end

    it 'When logged out, has user_id but is nil' do
      user = create :user
      login_as user
      post '/v2/search', { query: { type: 'Hospital' } }
      logout
      post '/v2/search', { query: { type: 'Hospital' } }
      t = TrackableLog.all.last
      expect(t.log['user_id']).to eq(nil)
    end

    it 'POSTed parameters are also recorded' do
      post '/v2/search', { query: { type: 'Hospital' } }
      t = TrackableLog.all.last
      expect(t.log['params']).to eq({"query"=>{"type"=>"Hospital"}})
    end

    it 'Empty POST' do
      post '/v2/search', {}
      t = TrackableLog.all.last
      expect(t.log['params']).to eq({})
    end
  end
end
