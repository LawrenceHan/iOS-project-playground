module ReviewExt
  extend ActiveSupport::Concern

  def username
    profile.try(:display_username)
  end

  def small_avatar
    if profile
      profile.small_avatar
    else
      UserAvatarUploader.new.small.default_url
    end
  end

  included do
    # FIXME: it generates strange sql
    #   SELECT  reviews.*, (NULL) as current_user_id FROM "reviews"
    # why we need current_user_id here?
    scope :search, -> (current_user_id) { includes(:profile).select("reviews.*").select("(#{current_user_id || 'NULL'}) as current_user_id") }

    delegate :social_friends, to: :profile, allow_nil: true

    delegate :name, to: :hospital, prefix: true, allow_nil: true
    delegate :h_class, to: :hospital, prefix: true, allow_nil: true
    delegate :avg_rating, to: :hospital, prefix: true, allow_nil: true
    delegate :avg_waiting_time, to: :hospital, prefix: true, allow_nil: true
    delegate :address, to: :hospital, prefix: true, allow_nil: true
    delegate :city, to: :hospital, prefix: true, allow_nil: true

    delegate :name, to: :physician, prefix: true, allow_nil: true
    delegate :gender, to: :physician, prefix: true, allow_nil: true
    delegate :position, to: :physician, prefix: true, allow_nil: true
    delegate :avg_rating, to: :physician, prefix: true, allow_nil: true
    delegate :human_specialities, to: :physician, prefix: true, allow_nil: true

    delegate :name, to: :medication, prefix: true, allow_nil: true
    delegate :code, to: :medication, prefix: true, allow_nil: true
    delegate :dosage, to: :medication, prefix: true, allow_nil: true
    delegate :companies, to: :medication, prefix: true, allow_nil: true
    delegate :avg_rating, to: :medication, prefix: true, allow_nil: true
    delegate :eph_name, to: :medication, prefix: true, allow_nil: true
  end

  module ClassMethods
    def create_by_data(current_user, data)
      me_id = data[:medical_experience_id]
      if me_id.present? && (medical_experience = current_user.medical_experiences.exists?(id: me_id))
        create(data)
      else
        medical_experience = current_user.medical_experiences.create
        create(data.merge({medical_experience: medical_experience}))
      end
    end


    def search_by(options)
      reviews = search(options[:current_user_id])

      intersect_sql = ""
      condition_ids = options[:condition_ids].to_a.delete_if(&:blank?).map(&:to_i)
      symptom_ids = options[:symptom_ids].to_a.delete_if(&:blank?).map(&:to_i)
      if condition_ids.present? and symptom_ids.present?
        intersect_sql = "COALESCE(array_length(array_intersect(ARRAY#{condition_ids}, medical_experiences.condition_ids), 1), 0) + COALESCE(array_length(array_intersect(ARRAY#{symptom_ids}, medical_experiences.symptom_ids), 1), 0)"
      elsif condition_ids.present?
        intersect_sql = "COALESCE(array_length(array_intersect(ARRAY#{condition_ids}, medical_experiences.condition_ids), 1), 0)"
      elsif symptom_ids.present?
        intersect_sql = "COALESCE(array_length(array_intersect(ARRAY#{symptom_ids}, medical_experiences.symptom_ids), 1), 0)"
      end
      if condition_ids.present? or symptom_ids.present?
        reviews.joins!(:medical_experience)
        reviews._select!("(#{intersect_sql}) AS matched_count").where!("(#{intersect_sql}) > 0").order!('matched_count DESC')
      end

      reviews
    end
  end
end
