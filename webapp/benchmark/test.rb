#!/usr/bin/env ruby
#############################################################
# bundle exec ruby benchmark/test.rb
# COUNT=100 CONCURRENCY=10 bundle exec ruby benchmark/test.rb
#############################################################
require 'typhoeus'
require 'json'

host = ARGV[0] || "api.staging.kangyu.co"
default_options = {
  cookiefile: "./cookies",
  cookiejar: "./cookies",
  headers: { 'Content-Type' => 'application/json' }
}

# register
Typhoeus.post(
  "http://#{host}/v1/account/register",
  default_options.merge(
    method: :post,
    body: '{"user":{"email":"new_user@thecarevoice.com","password":"123456","phone":"12345678901","sms_token":"1234"}}'
  )
)

# sign in
Typhoeus.post(
  "http://#{host}/v1/account/session",
  default_options.merge(
    method: :post,
    body: '{"user":{"email":"new_user@thecarevoice.com","password":"123456"}}'
  )
)

page_size = 25
default_iterate_size = 100
default_concurrency_size = 10
iterate_size = ENV["COUNT"] ? ENV["COUNT"].to_i : default_iterate_size

start = Time.now.to_f

physician_ids = []
review_ids = []

search_physicians_start = Time.now.to_f
hydra = Typhoeus::Hydra.new(max_concurrency: ENV["CONCURRENCY"] ? ENV["CONCURRENCY"].to_i : default_concurrency_size)
iterate_size.times do |i|
  search_req = Typhoeus::Request.new(
    "http://#{host}/v1/search/physicians?name=王",
    default_options.merge( method: :get )
  )
  search_req.on_complete do |response|
    if response.body.length > 0
      physicians = JSON.parse(response.body)
      physician_ids << physicians[i % page_size]["id"]
    end
  end
  hydra.queue(search_req)
end
hydra.run
puts "Search physicians average time: #{(Time.now.to_f - search_physicians_start) / iterate_size}"

post_physician_review_start = Time.now.to_f
hydra = Typhoeus::Hydra.new(max_concurrency: ENV["CONCURRENCY"] ? ENV["CONCURRENCY"].to_i : default_concurrency_size)
physician_ids.each do |physician_id|
  post_review_req = Typhoeus::Request.new(
    "http://#{host}/v1/reviews/physician",
    default_options.merge(
      method: :post,
      body: '{"review":{"reviewable_id":"'+physician_id.to_s+'","note":"good physician"}}'
    )
  )
  post_review_req.on_complete do |response|
    review = JSON.parse(response.body)
    review_ids << review['id']
  end
  hydra.queue(post_review_req)
end
hydra.run
puts "Post physician review average time: #{(Time.now.to_f - post_physician_review_start) / physician_ids.size}"

get_physician_review_start = Time.now.to_f
hydra = Typhoeus::Hydra.new(max_concurrency: ENV["CONCURRENCY"] ? ENV["CONCURRENCY"].to_i : default_concurrency_size)
review_ids.each do |review_id|
  get_review_req = Typhoeus::Request.new(
    "http://#{host}/v1/reviews/#{review_id}",
    default_options.merge( method: :get )
  )
  hydra.queue(get_review_req)
end
hydra.run
puts "Get physician review average time: #{(Time.now.to_f - get_physician_review_start) / review_ids.size}"

puts "Total time: #{Time.now.to_f - start}"
