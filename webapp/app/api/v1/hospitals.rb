module V1::Hospitals
  class API < Grape::API
    helpers CommonHelper
    helpers AuthorizeHelper

    resource :hospitals do
      desc "Return a hospital's details"
      params do
        requires :id, type: Integer, desc: "Hospital ID."
      end

      get ':id', requirements: { id: /[0-9]*/ } do
        attrs = [:id, :name, :official_name, :h_class, :address, :phone, :post_code, :avg_rating, :avg_waiting_time]
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
        reviews = HospitalReview.published.includes(:profile).where(reviewable_id: params[:id]).page(params[:page]).order("id desc")
        append_total_pages(reviews.total_pages)
        # Set the current user id to each reviews (for the promoted method)
        reviews.each {|r| r.current_user_id = current_user.id } if current_user

        say_succeed reviews.as_json(only:[:id, :created_at, :helpfuls_count, :avg_rating, :note],
                                    methods: [:username, :user_id, :small_avatar, :reviewable_name,
                                              :hospital_h_class, :hospital_address, :hospital_avg_rating, :hospital_avg_waiting_time, :human_conditions, :promoted])
      end
    end
  end
end
