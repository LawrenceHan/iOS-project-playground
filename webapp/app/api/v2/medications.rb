module V2::Medications
  class API < Grape::API
    helpers CommonHelper
    helpers AuthorizeHelper

    resource :medications do
      desc "Return a medication's details"
      params do
        requires :id, type: Integer, desc: "Medication ID"
      end
      get ':id', requirements: { id: /[0-9]*/ } do
        if medication = Medication.select(:id, :name, :code, :dosage1, :dosage2, :dosage3, :avg_rating).select(Medication.review_count_sql).find_by(id: params[:id])
          say_succeed medication.as_json(only: [:id, :name, :code, :avg_rating, :reviews_count],
                                        methods: [:company, :dosage, :reviews_count, :question_avg_ratings],
                                        include: {cardinal_health: {only: [:official_name,
                                                                           :common_name,
                                                                           :rx_otc,
                                                                           :company_name,
                                                                           :member_price,
                                                                           :sale_price,
                                                                           :indications,
                                                                           :usage,
                                                                           :warning,
                                                                           :adverse_reactions,
                                                                           :storage_type,
                                                                           :link] } })
        else
          say_failed I18n.t('api.record_not_found', id: params[:id], stuff: Medication.model_name.human)
        end
      end

      desc "Return a medication's reviews"
      params do
        optional :page, type: Integer, desc: 'page number'
        requires :id, type: Integer, desc: "Medication ID"
      end
      get ':id/reviews' do
        reviews = MedicationReview.includes(:profile, :medication).where(reviewable_id: params[:id]).order("created_at DESC").page(params[:page])
        append_total_pages(reviews.total_pages)

        # Set the current user id to each reviews (for the promoted method)
        reviews.each {|r| r.current_user_id = current_user.id } if current_user

        say_succeed reviews.as_json(only:[:id, :created_at, :helpfuls_count, :avg_rating, :note],
                                    methods: [:username, :user_id, :small_avatar, :reviewable_name, :medication_code,
                                              :medication_dosage, :medication_companies, :medication_avg_rating, :human_conditions, :human_symptoms, :human_health_conditions, :promoted])
      end
    end
  end
end
