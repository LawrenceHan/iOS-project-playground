module Trackable
  extend ActiveSupport::Concern
  included do

    before do |endpoint|
      # see: http://codetunes.com/2014/grape-part-II/
      keys = {
        'REMOTE_ADDR' => true,
        'SERVER_NAME' => true,
        'HTTP_ACCEPT' => true,
        'REQUEST_URI' => true,
        'HTTP_USER_AGENT' => true
      }

      env['trackable'] = {}

      # look up unprocessed headers too
      # since we want to iterate through all the headers, we do it once
      env.keys.map { |k|
        # shortcircuit if found in keys first
        if keys[k] or k.start_with?('X-TCV')
          env['trackable'][k] = env[k].force_encoding('UTF-8')
        end
      }

      env['trackable'][:params] = env['api.endpoint'].params.clone
      env['trackable'][:params].delete('route_info')
      env['trackable'][:params].delete('format')
      env['trackable'][:params]['user'] =  env['trackable'][:params]['user'].clone if env['trackable'][:params]['user']
      env['trackable'][:params]['user'].delete('password') if env['trackable'][:params]['user']

      #env['trackable'][:headers] = env['api.endpoint'].headers.to_hash
      env['trackable'][:request_id] = env['action_dispatch.request_id']
    end

    Warden::Manager.before_failure do |env, opts|
      if env['trackable']
        env['trackable'][:exception] = opts
        t = TrackableLog.create log: env['trackable'].to_json
        t.save
      end
    end

    # rescue_from Exception do |ex|
    #   env['trackable'][:exception] = ex.inspect
    #   t = TrackableLog.create log: env['trackable'].to_json
    #   t.save
    # end

    after do |endpoint|
      # status
      env['trackable'][:status] = env['api.endpoint'].status
      # user id
      if env['warden'].user and env['warden'].user.id
        env['trackable'][:user_id] = env['warden'].user.id
      else
        env['trackable'][:user_id] = nil
      end
      # create and save log
      t = TrackableLog.create log: env['trackable'].to_json
      t.save
    end
  end
end
