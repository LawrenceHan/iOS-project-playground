module V1::Search
  module HospitalSearch
    class API < Grape::API

      helpers CommonHelper

      # before do
      #   authenticate!
      # end

      resource :hospitals do
        desc 'Return nearby hospitals'
        params do
          optional :page, type: Integer, desc: 'page number'
          requires :lat, type: Float, desc: 'Current latitude'
          requires :lng, type: Float, desc: 'Current longitude'
          optional :scope, type: Float, desc: 'Search distance scope, unit is km'
          optional :ranking, type: Boolean, desc: 'Order by Ranking flag'
        end
        get :nearby do
          scope = (params[:scope].presence || 1).to_f
          attrs = [:id, :name, :address, :h_class, :avg_rating, :latitude, :longitude, :ownership]
          hospitals = Hospital.nearby(params[:lat], params[:lng], scope).select(attrs).select(Hospital.review_count_sql).page(params[:page])
          hospitals.reorder!(avg_rating: :desc) if params[:ranking]
          append_total_pages(hospitals.total_pages)
          say_succeed hospitals.as_json(only: attrs + [:reviews_count], methods: :human_distance )
        end

        # TODO: for the end-user would be nicer if every search had a default
        # area I can find hospitals from India even when searching from China
        desc 'Return hospitals within area'
        params do
          optional :page, type: Integer, desc: 'page number'
          requires :lat, type: Float, desc: 'Current latitude'
          requires :lng, type: Float, desc: 'Current longitude'
          requires :sw_lat, type: Float, desc: 'South-west corner latitude'
          requires :sw_lng, type: Float, desc: 'South-west corner longitude'
          requires :ne_lat, type: Float, desc: 'North-east corner latitude'
          requires :ne_lng, type: Float, desc: 'North-east corner longitude'
          optional :ranking, type: Boolean, desc: 'Order by Ranking flag'
        end
        get :within_area do
          attrs = [:id, :name, :address, :h_class, :avg_rating, :latitude, :longitude, :ownership]
          hospitals = Hospital.within_area(params[:lat], params[:lng], params[:sw_lat], params[:sw_lng], params[:ne_lat], params[:ne_lng]).select(attrs).select(Hospital.review_count_sql).page(params[:page]).per(50)
          hospitals.reorder!(avg_rating: :desc) if params[:ranking]
          append_total_pages(hospitals.total_pages)
          say_succeed hospitals.as_json(only: attrs + [:reviews_count], methods: :human_distance )
        end

        desc 'Search Hospitals by name'
        params do
          optional :page, type: Integer, desc: 'page number'
          requires :name, type: String, desc: 'Hospital name'
          optional :lat, type: Float, desc: 'Current latitude'
          optional :lng, type: Float, desc: 'Current longitude'
          optional :ranking, type: Boolean, desc: 'Order by Ranking flag'
        end
        get :by_name do
          attrs = [:id, :name, :address, :h_class, :avg_rating, :latitude, :longitude, :ownership]
          hospitals = Hospital.where('UPPER(name) like UPPER(?)', "%#{params[:name]}%").select(attrs).select(Hospital.review_count_sql).page(params[:page])
          hospitals = hospitals.order_by_distance(params[:lat], params[:lng]) if params[:lat].present? and params[:lng].present?
          hospitals.reorder!(avg_rating: :desc) if params[:ranking]
          append_total_pages(hospitals.total_pages)
          say_succeed hospitals.as_json(only: attrs + [:reviews_count], methods: :human_distance )
        end


        desc 'Return hospital departments with physicians count'
        params do
          requires :id, type: Integer, desc: "Hospital ID."
        end
        # FIXME: it's not a search api, it just lists all departments for a hospital
        get ':id/departments' do
          if hospital = Hospital.find_by(id: params[:id])
            departments = hospital.departments
                .joins(:physicians)
                .select('departments.id, departments.name, count(physicians.*) AS physicians_count')
                .group('departments.id, departments.name')

            say_succeed departments.as_json(
              only: [:id, :name, :physicians_count])
          else
            say_failed I18n.t('api.record_not_found', id: params[:id], stuff: Hospital.model_name.human)
          end
        end
      end

    end
  end
end
