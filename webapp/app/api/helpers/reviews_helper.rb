module ReviewsHelper
  def format_params_data
    data = get_params_data(:medical_experience,
                           [:referral_code, :is_anonymous, { symptom_ids: []}, { condition_ids: []}, :network_visible, :behalf,{reviews_attributes: [:dosage, :intake_frequency, :duration, :adverse_effects, :note, :type, :reviewable_id, :is_anonymous, {answers_attributes: [:review_id, :question_id, :waiting_time, :rating, :price]}]}])

    # data = get_params_data(:medical_experience,
    #                        [:referral_code, :is_anonymous, { symptom_ids: []}, { condition_ids: []}, :network_visible, :behalf])

    # # Permit the entire review_attributes node. In review's creation we do similarly
    # if _params[:medical_experience] and _params[:medical_experience][:reviews_attributes]
    #   data[:reviews_attributes] = _params[:medical_experience][:reviews_attributes]
    # end

    data[:condition_ids].map!(&:to_i) if data[:condition_ids].present?
    data[:symptom_ids].map!(&:to_i) if data[:symptom_ids].present?
    data
  end

  def get_review_class
    case params[:type]
    when 'hospital'   then ::HospitalReview
    when 'physician'  then ::PhysicianReview
    when 'medication' then ::MedicationReview
    end
  end

  def jsonify(reviews)
    reviews.as_json(only: [:id, :created_at, :helpfuls_count, :avg_rating, :note],
                    methods: [:reviewable_name, :username, :user_id, :small_avatar, :promoted])
  end
end
