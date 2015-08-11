module V2::Hospitals
  class API < Grape::API
    helpers CommonHelper
    helpers AuthorizeHelper

    resource :hospitals do
      desc "Return all hospital names"
      get '' do
        language = I18n.locale.to_s.split('-').first
        language = 'en' if language != 'zh'
        hospitals = Hospital.has_physicians.with_translations(I18n.locale.to_s, language).select("hospitals.id, hospitals.name").order('hospital_translations.name asc')
        hospitals.where!(id: params[:hospital_ids]) if params[:hospital_ids].present?
        say_succeed hospitals.map { |hospital| { id: hospital.id, name: hospital.name } }
      end

      desc "Return a hospital's details"
      params do
        requires :id, type: Integer, desc: "Hospital ID."
      end

      get ':id', requirements: { id: /[0-9]*/ } do
        attrs = [:id, :name, :official_name, :h_class, :address, :phone, :post_code, :avg_rating, :avg_waiting_time, :ownership]
        if hospital = Hospital.select(attrs).select(Hospital.review_count_sql).find_by(id: params[:id])
          say_succeed hospital.as_json(only: attrs + [:reviews_count] - [:avg_waiting_time], methods: [:human_avg_waiting_time, :question_avg_ratings, :highly_reviews_departments])
        else
          say_failed I18n.t('api.record_not_found', id: params[:id], stuff: Hospital.model_name.human)
        end
      end

      desc "Return a hospital's reviews"
      params do
        optional :page, type: Integer, desc: 'page number'
        requires :id, type: Integer, desc: "Hospital ID."
      end
      get ':id/reviews' do
        reviews = HospitalReview.includes(:profile).where(reviewable_id: params[:id]).order("created_at desc").page(params[:page])
        append_total_pages(reviews.total_pages)
        # Set the current user id to each reviews (for the promoted method)
        reviews.each {|r| r.current_user_id = current_user.id } if current_user

        say_succeed reviews.as_json(only:[:id, :created_at, :helpfuls_count, :avg_rating, :note],
                                    methods: [:username, :user_id, :small_avatar, :reviewable_name,
                                              :hospital_h_class, :hospital_address, :hospital_avg_rating, :hospital_avg_waiting_time, :human_conditions, :human_symptoms, :human_health_conditions, :promoted])
      end
    end
  end
end
