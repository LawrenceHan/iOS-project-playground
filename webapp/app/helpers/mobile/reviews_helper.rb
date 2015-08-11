module Mobile
  module ReviewsHelper
    REVIEW_TAB = {
      hospital: I18n.t('search.hospitals'),
      physician: I18n.t('search.doctors'),
      medication: I18n.t('search.drugs')
    }

    DOSAGE_UNITS = %w(MG G IU % ML U MCG ML UI/ML U/ML)
    DOSAGE_UNITS_CN = %w(毫克 克 毫升 国际单位 ％ 单位 微克 国际单位／毫升 单位／毫升)
    INTAKE_FREQUENCIES = ["3 times a day", "twice a day", "once a day", "twice a week",
                          "once a week", "once or twice a month", "longer frequency"]
    INTAKE_FREQUENCIES_CN = ["每天三次","每天两次","每天一次","每周两次","每周一次","每月一次或两次","间隔更长"]
    DURATION_UNITS = ["day(s)", "week(s)", "month(s)", "year(s)"]
    DURATION_UNITS_CN = ["天","周","月","年"]

    def dosage_units
      if I18n.locale == :en
        return DOSAGE_UNITS
      elsif I18n.locale == :"zh-CN"
        return DOSAGE_UNITS_CN
      end
    end

    def intake_frequencies
      if I18n.locale == :en
        return INTAKE_FREQUENCIES
      elsif I18n.locale == :"zh-CN"
        return INTAKE_FREQUENCIES_CN
      end
    end

    def duration_units
      if I18n.locale == :en
        return DURATION_UNITS
      elsif I18n.locale == :"zh-CN"
        return DURATION_UNITS_CN
      end
    end

    def review_type
      case @review.type
      when 'HospitalReview' then 'hospital'
      when 'PhysicianReview' then 'physician'
      when 'MedicationReview' then 'medication'
      end
    end

    def review_class(type)
      case type
      when 'hospital'   then ::HospitalReview
      when 'physician'  then ::PhysicianReview
      when 'medication' then ::MedicationReview
      end
    end
    module_function :review_class

    def linked_to_network_class(review=nil)
      review ||= @review
      return nil if review.blank?
      'linked_to_network' if current_user && review.from_social_network_of_user_id(current_user.id)
    end

    def report_url(review_id)
      email = "umesh.sengar@thecarevoice.com"
      subject = Rack::Utils.escape("Reporting inappropriate review ##{review_id}")
      body = Rack::Utils.escape %Q(

        Review ID: #{review_id}
        link: #{mobile_review_url(review_id)}
      )

      "mailto:#{email}?subject=#{subject}&body=#{body}"
    end


    def proceed_to_path(object, opts={})
      case object
      when :hospital
        path =
          if params[:view_physicians]
            '/mobile/hospitals/{{hospital.id}}/physicians'
          elsif params[:view_departments]
            '/mobile/hospitals/{{hospital.id}}/departments'
          elsif params[:proceed_to] == 'new_review'
            '/mobile/hospitals/{{hospital.id}}/reviews/new'
          else
            '/mobile/hospitals/{{hospital.id}}'
          end

        extra_params = params.slice(:proceed_to)

        if extra_params.present?
          path + '?' + extra_params.to_query
        else
          path
        end
      when Physician
        if params[:proceed_to] == 'new_review'
          new_mobile_physician_review_path(object)
        else
          mobile_physician_path(object)
        end
      when Medication
        if params[:proceed_to] == 'new_review'
          new_mobile_medication_review_path(object)
        else
          mobile_medication_path(object)
        end
      when :speciality
        if params[:proceed_to]
          "/mobile/specialities/{{speciality.id}}/physicians?proceed_to=#{params[:proceed_to]}"
        else
          '/mobile/specialities/{{speciality.id}}/physicians'
        end
      end
    end

    def hospital_name_with_h_class
      #{@review.reviewable_name}
      output = @review.reviewable_name.to_s
      @review.hospital_h_class.present? && output << "(#{@review.hospital_h_class})"
      output
    end
  end
end
