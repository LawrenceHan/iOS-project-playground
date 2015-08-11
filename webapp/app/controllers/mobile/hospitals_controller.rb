module Mobile
  class HospitalsController < BaseController
    ReviewCountJoins = "LEFT OUTER JOIN reviews ON reviews.reviewable_id = hospitals.id " +
                       "AND reviews.type IN ('HospitalReview') AND reviews.status = 'published'"
    def index
    end

    def in_area
      return unless params[:bounds].present?
      bounds = params.require(:bounds)
      if params[:baidu_location]
        lo_lat, lo_lng, hi_lat, hi_lng = bounds.map(&:to_f)
      elsif params[:google_location]
        lo_lat, lo_lng, hi_lat, hi_lng = bounds.split(",").map(&:to_f)
      end
      c_lat = (lo_lat + hi_lat) / 2
      c_lng = (lo_lng + hi_lng) / 2
      @hospitals = Hospital.where(
        "hospitals.latitude > ? AND hospitals.latitude < ? AND hospitals.longitude > ? AND hospitals.longitude < ?",
        lo_lat, hi_lat, lo_lng, hi_lng) \
        .order("distance_in_km(hospitals.latitude, hospitals.longitude, #{c_lat}, #{c_lng}) ASC") \
        .limit(100)

      load_reviews_count
      load_distance
      sorting
    end

    def search
      name = params[:q].present? ? params.require(:q) : ""
      @hospitals = AggregatedSearch.search(query: { type: 'Hospital', text: name }, page: params[:page]).map { |searchable|
        entity = searchable.searchable_entity
        entity.distance = searchable.attributes['distance'] if searchable.attributes['distance']
        entity.avg_rating = searchable.attributes['avg_rating']
        entity.reviews_count = searchable.attributes['reviews_count']
        entity
      }.uniq

      load_reviews_count
      load_distance
      sorting
      render :in_area
    end

    def show
      @record = Hospital.select([:id, :name, :official_name, :h_class, :address, :phone, :post_code, :city, :avg_rating, :avg_waiting_time]).select(Hospital.review_count_sql).find(params[:id])

      @highly_reviews_departments = @record.highly_reviews_departments
      @required_questions, @optional_questions = @record.question_avg_ratings, []

      render 'profile'
    end


    def css_namespace
      action_name == 'show' ? 'physicians-controller' : super
    end

    protected
    def load_reviews_count
      reviews_counts = Hospital.joins(ReviewCountJoins) \
        .where(id: @hospitals.map(&:id)).group('hospitals.id') \
        .count('reviews.*')

      @hospitals.each do |hospital|
        hospital.reviews_count = reviews_counts[hospital.id]
      end
    end

    def load_distance
      if !params[:baidu_location].blank?
        current_location = params[:baidu_location].map(&:to_f)
        current_location = [current_location[1], current_location[0]]
      elsif !params[:google_location].blank?
        current_location = params[:google_location].split(",").map(&:to_f)
      else
        current_location = nil
      end

      if current_location
        @hospitals.each do |hospital|
          hospital.distance = (hospital.distance_to(current_location, :km) * 1000).ceil
        end
      end
    end

    def sorting
      return unless params[:type]
      if params[:type] == "distance"
        @hospitals = @hospitals.sort{|a, b| a.distance <=> b.distance}
      else
        @hospitals = @hospitals.sort{|a, b| b.avg_rating <=> a.avg_rating}
      end
    end
  end
end
