module V1::Reviews
  module MedicalExperiences
    class API < Grape::API

      resource :medical_experiences do
        desc "Return current user's medical experiences [require login]"
        params do
          optional :page, type: Integer, desc: 'page number'
        end
        get do
          authenticate!
          medical_experiences = current_user.medical_experiences.includes(:published_hospital_review, :published_physician_reviews, :published_medication_reviews, :hospital, :physicians, :medications).order('medical_experiences.created_at DESC').page(params[:page])
          append_total_pages(medical_experiences.total_pages)
          say_succeed medical_experiences.map(&:api_data)
        end

        desc 'Return medical experience details [require login]'
        params do
          requires :id, type: Integer, desc: "Medical Experience ID."
        end

        get ':id', requirements: { id: /[0-9]*/ } do
          authenticate!
          if m = MedicalExperience.includes(:published_physician_reviews, :published_medication_reviews, :physicians, :medications).find_by(id: params[:id])
            json_config = {only: [:id, :updated_at, :reviewable_id, :note], methods: :reviewable_name}
            say_succeed m.as_json({only: [:id, :completion, :updated_at, :behalf, :hospital_id, :network_visible],
                                   methods: [:conditions, :symptoms],
                                   include: { hospital: { only: [:id, :name] } }
                                  }).merge(
                                    hospital_review: m.published_hospital_review.as_json(json_config),
                                    physician_reviews: m.published_physician_reviews.as_json(json_config),
                                    medication_reviews: m.published_medication_reviews.as_json(json_config)
                                  )
          else
            say_failed I18n.t('api.record_not_found', id: params[:id], stuff: MedicalExperience.model_name.human)
          end
        end

        desc 'Create a new medical experience [require login]'
        params do
          requires :medical_experience, type: Hash do
            optional :hospital_id, type: Integer, desc: 'hospital ID'
            optional :condition_ids, type: Array, desc: 'condition ids array'
            optional :symptom_ids, type: Array, desc: 'symptom ids array'
            requires :network_visible, type: Boolean, desc: 'network visible'
            optional :behalf, type: String, desc: 'this field indicates if you create medical experience by yourself or on behalf of somebody'
          end
        end
        post do
          authenticate!
          medical_experience = current_user.medical_experiences.new(format_params_data)
          if medical_experience.save
            say_succeed medical_experience
          else
            say_failed medical_experience
          end
        end

        desc 'Edit a medical experience [require login]'
        params do
          requires :medical_experience, type: Hash do
            optional :condition_ids, type: Array, desc: 'condition ids array'
            optional :symptom_ids, type: Array, desc: 'symptom ids array'
            optional :network_visible, type: Boolean, desc: 'network visible'
            optional :behalf, type: String, desc: 'this field indicates if you create medical experience by yourself or on behalf of somebody'
            optional :reviews_attributes, type: Array, desc: 'add reviews in batch'
          end
        end
        put ':id' do
          authenticate!
          medical_experience = current_user.medical_experiences.where(id: params[:id]).first
          if medical_experience && medical_experience.update(format_params_data)
            say_succeed
          else
            # FIXME: if medical_experience can't be found, its response body is "null"
            say_failed medical_experience
          end
        end

        desc 'Calculate completion and avg_rating for iOS local medical_experience'
        params do
          requires :medical_experience, type: Hash do
            optional :hospital_id, type: Integer, desc: 'hospital ID'
            optional :condition_ids, type: Array, desc: 'condition ids array'
            optional :symptom_ids, type: Array, desc: 'symptom ids array'
            optional :network_visible, type: Boolean, desc: 'network visible'
            optional :behalf, type: String, desc: 'this field indicates if you create medical experience by yourself or on behalf of somebody'
            optional :hospital_review, type: Hash, desc: 'hospital review'
            optional :physician_reviews, type: Array, desc: 'physician reviews'
            optional :medication_reviews, type: Array, desc: 'medication reviews'
          end
        end
        post :calculation_for_local do
          m = MedicalExperience.new(_params.require(:medical_experience).permit!)
          m.calculate_completion_and_avg_rating
          m.created_at = Time.now
          say_succeed m.api_data
        end

      end
    end
  end
end
