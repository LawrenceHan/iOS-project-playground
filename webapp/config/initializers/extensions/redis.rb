require 'redis-namespace'

redis_connection = Redis.new
$redis = Redis::Namespace.new("carevoice_#{Rails.env}", :redis => redis_connection)
