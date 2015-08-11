module V1::Search
  module PhysicianSearch
    class API < Grape::API

      helpers CommonHelper

      # before do
      #   authenticate!
      # end

      resource :physicians do
        desc 'Search physicians'
        params do
          optional :page, type: Integer, desc: 'page number'
          # Search by name
          optional :name, type: String, desc: 'Physician name 【Search by name】'

          # Search by hospital
          optional :hospital_id, type: Integer, desc: 'Hospital ID【Search by hospital】'

          # Search by department
          optional :department_id, type: Integer, desc: 'Department ID【Search by hospital】'

          # Search by speciality
          optional :speciality_id, type: Integer, desc: 'Speciality ID【Search by speciality】'

          # Sort by distance
          optional :lat, type: Float, desc: 'Current latitude (Sort by distance)'
          optional :lng, type: Float, desc: 'Current Longitude (Sort by distance)'
          optional :scope, type: Float, desc: 'Search distance scope, unit is km (Sort by distance)'

          # Sort by rating
          optional :ranking, type: Boolean, desc: 'Order by Ranking flag (Sort by rating)'
        end
        get do
          physicians = Physician.joins(:hospital).preload(:hospital, :department, :specialities).page(params[:page])
          physicians._select!('physicians.id, physicians.hospital_id, physicians.department_id, physicians.birthdate, physicians.name, physicians.gender, physicians.position, physicians.avg_rating')
          physicians._select!(Physician.review_count_sql) # reviews_count

          # Search by name
          physicians.where!('UPPER(physicians.name) like UPPER(?)', "%#{params[:name]}%") if params[:name].present?

          # Search by hospital
          physicians.where!(hospital_id: params[:hospital_id]) if params[:hospital_id].present?

          # Search by department
          physicians.joins!(:department).where!(department_id: params[:department_id]) if params[:department_id].present?

          # Search by speciality
          physicians.joins!(:specialities).where!('specialities.id = ?', params[:speciality_id]) if params[:speciality_id].present?

          if (params[:lat].present? and params[:lng].present?)
            distance_sql = "distance_in_km(hospitals.latitude, hospitals.longitude, #{params[:lat]}, #{params[:lng]})"
            physicians._select!(distance_sql + ' AS distance')
          end

          if params[:ranking] # Order by Ranking
            physicians.order!(avg_rating: :desc)
          elsif (params[:lat].present? and params[:lng].present?) # Order by distance
            scope = (params[:scope].presence || 10000).to_f
            distance_sql = "distance_in_km(hospitals.latitude, hospitals.longitude, #{params[:lat]}, #{params[:lng]})"
            physicians.where!(distance_sql + ' <= ?', scope)._select!(distance_sql + ' AS distance').order!('distance')
          end

          append_total_pages(physicians.total_pages)
          say_succeed physicians.as_json(only: [:id, :hospital_id, :name, :gender, :avg_rating, :position, :reviews_count], methods: [:age, :human_distance, :department_name, :human_specialities, :hospital_name, :hospital_h_class] )
        end
      end

    end
  end
end
