module V2
  module Reviews
    class API < Grape::API
      helpers AuthorizeHelper
      helpers ReviewsHelper

      namespace :reviews do
        mount MedicalExperiences::API
        mount Answers::API
        mount Questions::API
      end

      before do
        authenticate!
      end

      resource :reviews do
        desc 'Get all reviews [require login]'
        params do
          optional :page, type: Integer, desc: 'page number'
        end
        get '/' do
          reviews = current_user.reviews.order('created_at DESC').page(params[:page])
          append_total_pages(reviews.total_pages)
          say_succeed reviews.as_json(methods: [:class_name, :reviewable_name, :notifiable])
        end

        desc 'Create a new review [require login]'
        params do
          requires :type, type: String, desc: 'review type, should be one of [hospital,physician,medication]', regexp: /^hospital|physician|medication$/
          requires :review, type: Hash do
            requires :reviewable_id, type: Integer, desc: 'hospital_id or physician_id or medication_id'
            optional :medical_experience_id, type: Integer, desc: 'medical experience id'
            optional :health_condition_id, type: Integer, desc: 'condition or symptom id'
            optional :note, type: String, desc: 'note'
            # why are these not part of answers_attributes?
            optional :dosage_count, type: Integer, desc: 'dosage count (only for medication review)'
            optional :dosage_unit, type: String, desc: 'dosage unit (only for medication review)'
            optional :intake_frequency, type: String, desc: 'intake frequency (only for medication review)'
            optional :duration_count, type: Integer, desc: 'duration count (only for medication review)'
            optional :duration_unit, type: String, desc: 'duration unit (only for medication review)'
            optional :adverse_effects, type: String, desc: 'adverse effects (only for medication review)'
            optional :answers_attributes, type: Array, desc: 'ratings for this review'
          end
        end
        post ':type' do
          health_condition_id = params[:review].delete(:health_condition_id)
          klass = get_review_class
          data = _params.require(:review).permit!

          if data[:answers_attributes]
            result = data[:answers_attributes].map {|json| json.kind_of?(String) ? JSON.parse(json) : json}
            data[:answers_attributes] = result
          end

          review = klass.create_by_data(current_user, data)

          if health_condition_id && (health_condition = HealthCondition.find_by id: health_condition_id)
            if health_condition.type == 'Symptom'
              review.medical_experience.update symptom_ids: [health_condition_id]
            else
              review.medical_experience.update condition_ids: [health_condition_id]
            end
          end
          if review.errors.empty?
            say_succeed review.as_json(only: [:id, :medical_experience_id, :created_at, :note],
                                       methods: [:reviewable_name, :notifiable, :user_id])
          else
            say_failed review
          end
        end

        desc 'Review profile'
        params do
          requires :id, type: Integer, desc: "Review ID."
        end

        get ':id', requirements: { id: /[0-9]*/ } do
          if review = Review.includes(:profile, :questions).find_by(id: params[:id])
            review.current_user = current_user
            json_config = {
              only:[:id, :created_at, :helpfuls_count, :avg_rating, :note],
              include: {answers:
                        { only: [:rating],
                          methods: [:human_waiting_time, :question_type, :question_content, :question_is_optional]}},
              methods: [:already_marked_as_helpful, :username, :small_avatar, :reviewable_name, :notifiable, :reviewable_id, :user_id]
            }
            case review.type
            when 'HospitalReview'
              json_config[:methods].concat([:hospital_h_class, :hospital_address, :hospital_avg_rating,
                                            :hospital_human_avg_waiting_time, :human_conditions, :human_symptoms, :human_health_conditions])
              say_succeed review.as_json(json_config)
            when 'PhysicianReview'
              json_config[:methods].concat([:physician_gender, :physician_position, :physician_avg_rating,
                                            :physician_human_avg_waiting_time, :physician_human_avg_price,
                                            :human_conditions, :human_symptoms, :human_health_conditions])
              say_succeed review.as_json(json_config)
            when 'MedicationReview'
              json_config[:methods].concat([:medication_code, :medication_dosage, :medication_companies,
                                            :medication_avg_rating, :human_conditions, :human_symptoms, :human_health_conditions])
              say_succeed review.as_json(json_config)
            end
          else
            say_failed I18n.t('api.record_not_found', id: params[:id], stuff: Review.model_name.human)
          end
        end

        desc 'Mark a review as helpful [require login]'
        params do
          requires :id, type: Integer, desc: "Review ID"
        end
        put ':id/helpful' do
          # TODO: is this really  more efficient than doing a Review.find and comparing user id?
          if (review = current_user.reviews.find_by(id: params[:id]))
            say_failed 'Cannot mark your own review as helpful'
          else
            review = Review.find(params[:id])
            helpful = Helpful.where(review_id: params[:id], user_id: current_user.id).first_or_initialize
            if helpful.persisted? || helpful.save
              say_succeed
            else
              say_failed helpful
            end
          end
        end


        desc 'Update review note'
        params do
          requires :id, type: Integer, desc: "Review ID"
          requires :review, type: Hash do
            requires :note, type: String, desc: "Note"
          end
        end
        put ':id' do
          @review = current_user.reviews.find(params[:id])

          if Time.now - @review.created_at > 1.day
            # FIXME: other error format is error: ['error message']
            say_failed(error: I18n.t('api.reviews.edit_review_expired'))
          elsif @review.update(_params.require(:review).permit(:note))
            say_succeed
          else
            say_failed @review
          end
        end

      end

    end
  end
end
