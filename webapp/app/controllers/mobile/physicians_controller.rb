module Mobile
  class PhysiciansController < BaseController
    # search by name
    def index
      if params[:hospital_id]
        @hospital = Hospital.find(params[:hospital_id])
        scope =
          if params[:department_id]
            @department = @hospital.departments.find(params[:department_id])
            @department.physicians.where(["physicians.hospital_id = ?", params[:hospital_id]])
          else
            @hospital.physicians
          end

        @physicians = scope.includes(:specialities, :hospital).order(:name).page(params[:page])

        load_review_counts
        @has_more = @physicians.current_page < @physicians.total_pages
        @hide_search = true
      elsif params[:speciality_id]
        @speciality = Speciality.find(params[:speciality_id])
        @physicians = @speciality.physicians.includes(:specialities, :hospital)

        sorting

        load_review_counts
        @has_more = @physicians.current_page < @physicians.total_pages
        @hide_search = true
      elsif params[:doctor_name].present?
        search
      end

      if request.xhr?
        set_has_more_header @physicians
        render @physicians, layout: false
      else
        render
      end
    end

    def show
      @record = Physician.select(
          :id, :hospital_id, :name, :department_id, :gender, :birthdate, :position,
          :avg_rating, :avg_waiting_time, :avg_price, :vendor_id, :doc
        ).select(Physician.review_count_sql).find(params[:id])

      if @record.nil?
        render 'Not found', :status => '404'
        return
      end

      @required_questions, @optional_questions = @record.question_avg_ratings, []

      render 'profile'
    end

    protected
    def sorting
      params[:type] = "distance" unless params[:type]

      if request.location and request.location.data
        @current_location = [request.location.data["latitude"], request.location.data["longitude"]]
      end
      @physicians.each do |physician|
        if @current_location and physician.hospital.present?
          physician.distance = (physician.hospital.distance_to(@current_location, :km) * 1000).ceil
        else
          physician.distance = 1.0/0 # Infinity
        end
      end

      if params[:type] == "distance"
        @physicians = @physicians.sort{|a, b| a.distance <=> b.distance}
      else
        @physicians = @physicians.sort{|a, b| b.avg_rating <=> a.avg_rating}
      end

      @physicians = Kaminari.paginate_array(@physicians).page(params[:page])
    end

    def search
      doctor_name = params[:doctor_name] || ''
      options = { query: { type: 'Physician', text: doctor_name } }
      if params[:ranking]
        options[:sort] = { ranking: true }
      end
      @physicians = AggregatedSearch.search(options).map { |searchable|
        entity = searchable.searchable_entity
        entity.distance = searchable.attributes['distance'] if searchable.attributes['distance']
        entity.avg_rating = searchable.attributes['avg_rating']
        entity.reviews_count = searchable.attributes['reviews_count']
        entity
      }.uniq

      # Eager load hospitals manually
      # .include method in the previous @physicians relation causes an SQL error.
      hospitals = Hospital.where(id: @physicians.map(&:hospital_id).uniq).group_by(&:id)
      @physicians.each do |physician|
        physician.hospital = hospitals[physician.hospital_id].first if hospitals[physician.hospital_id]
      end

      sorting

      load_review_counts

      @has_more = @physicians.current_page < @physicians.total_pages
    end

    def load_review_counts
      joins = "LEFT OUTER JOIN reviews ON reviews.reviewable_id = physicians.id " +
              "AND reviews.type IN ('PhysicianReview') AND reviews.status = 'published'"
      reviews_counts = Physician.joins(joins) \
        .where(id: @physicians.map(&:id)).group('physicians.id') \
        .count('reviews.*')

      @physicians.each do |physician|
        physician.reviews_count = reviews_counts[physician.id]
      end
    end
  end
end
