module V2::Search
  class API < Grape::API
    include Trackable

    helpers CommonHelper

    desc 'Search for everything'
    params do
      optional :query, type: Hash do
        optional :text, type: String, desc: 'query by text'
        optional :type, type: String, desc: 'query by type, could be one or many of [Hospital,Department,Physician,Condition,HealthCondition,Symptom,Medication,Speciality,HospitalReview,MedicationReview,PhysicianReview]'
        optional :hospital_id, type: Integer, desc: 'query by hospital'
        optional :department_id, type: Integer, desc: 'query by department'
        optional :physician_id, type: Integer, desc: 'query by physician'
        optional :medication_id, type: Integer, desc: 'query by medication'
        optional :speciality_id, type: Integer, desc: 'query by speciality'
        optional :user_id, type: Integer, desc: 'query by user'
        optional :area, type: Hash, desc: 'query within area' do
          requires :lat, type: Float, desc: 'current latitude'
          requires :lng, type: Float, desc: 'current longitude'
          requires :sw_lat, type: Float, desc: 'south west latitude of area'
          requires :sw_lng, type: Float, desc: 'south west longitude of area'
          requires :ne_lat, type: Float, desc: 'north east latitude of area'
          requires :ne_lng, type: Float, desc: 'north east longitude of area'
        end
        optional :nearby, type: Hash, desc: 'query nearby' do
          requires :lat, type: Float, desc: 'current latitude'
          requires :lng, type: Float, desc: 'current longitude'
          requires :distance, type: Float, desc: 'search distance, unit is km'
        end
      end
      optional :sort, type: Hash do
        optional :ranking, type: Boolean, desc: 'sort by avg top rated'
        optional :reviews_count, type: Boolean, desc: 'sort by reviews count'
        optional :h_class, type: Boolean, desc: 'sort by h_class ("三级甲等")'
        optional :created_at, type: Boolean, desc: 'sort by created_at'
        optional :distance, type: Hash, desc: 'sort by distance' do
          requires :lat, type: Float, desc: 'current latitude'
          requires :lng, type: Float, desc: 'current longitude'
        end
      end
      optional :page, type: Integer, desc: 'page number'
      optional :per_page, type: Integer, desc: 'how many results in one page'
      optional :locale, type: String, desc: 'locale, should be one of [en-US,zh-CN]', values: %w(en-US zh-CN)
      optional :cache, type: Boolean
    end
    post '/search' do
      result = params[:cache] ? MaterializedAggregatedSearch.search(params) : AggregatedSearch.search(params)

      status 200
      response_objects = result.map { |searchable|
        entity = searchable.searchable_entity
        entity.distance = searchable.attributes['distance'] if searchable.attributes['distance']
        entity.avg_rating = searchable.attributes['avg_rating']
        entity.reviews_count = searchable.attributes['reviews_count']
        entity
      }.uniq
      results = if response_objects.all? { |ro| ro.is_a? HealthCondition }
                  response_objects.group_by(&:category).map do |category, lists|
                    { name: category, objects: lists.map(&:searchable_json) }
                  end
                else
                  response_objects.map(&:searchable_json)
                end
      { total_pages: result.total_pages, total_count: result.total_count, results: results }
    end
  end
end
