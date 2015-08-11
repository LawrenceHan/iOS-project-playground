module Mobile::MedicalExperiencesHelper
  def add_hospital_review_path
    if @medical_experience.hospital_id
      new_mobile_hospital_review_path(@medical_experience.hospital_id)
    else
      mobile_hospitals_path(proceed_to: 'new_review')
    end
  end

  def add_physician_review_path
    if @medical_experience.hospital_id
      mobile_hospital_physicians_path(@medical_experience.hospital_id, params: {proceed_to: 'new_review'})
    else
      mobile_search_physician_path(proceed_to: 'new_review', view_departments: '1')
    end
  end

  def edit_conditions_path(medical_experience)
    if medical_experience.new_record?
      "javascript:createMEAndEditConditions()"
    else
      mobile_medical_experience_health_conditions_path(medical_experience)
    end
  end

  def reorder_reviews(reviews)
    grouped = reviews.group_by(&:type)

    ['HospitalReview', 'PhysicianReview', 'MedicationReview'].each do |review_type|
      unless grouped.has_key?(review_type)
        grouped[review_type] = [
          OpenStruct.new(type: review_type,
                         reviewable_name: I18n.t('review.no_review_added'),
                         completion: 0)
        ]
      end
    end.map do |review_type|
      grouped[review_type]
    end.flatten
  end
end
