module Mobile
  module SearchHelper
    SEARCH_TAB = {
      distance: I18n.t('search.distance'),
      avg_rating: I18n.t('search.avg_rating')
    }

    def review_type_tab_class(type)
      return 'active' if params[:type].blank? && (type.to_s == 'hospital' || type.to_s == 'distance')
      type.to_s == params[:type] ? 'active' : nil
    end

    def back_path
      case params[:proceed_to]
      when 'new_review'; new_mobile_medical_experience_path
      else;              mobile_search_path
      end
    end

    def title_length
      if I18n.locale == :"zh-CN"
        15
      else
        25
      end
    end

    def review_length
      if I18n.locale == :"zh-CN"
        60
      else
        100
      end
    end
  end
end
