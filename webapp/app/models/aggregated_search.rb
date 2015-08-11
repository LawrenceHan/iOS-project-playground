class AggregatedSearch < ActiveRecord::Base
  self.primary_key = nil

  belongs_to :searchable_entity,
    :polymorphic => true,
    :foreign_key => :searchable_id,
    :foreign_type => :entity_type

  scope :search_by_text, ->(text) { where("content like LOWER(?)", "%#{text}%") }
  scope :nearby, ->(lat, lng, distance) { where("distance_in_km(latitude, longitude, #{lat}, #{lng}) <= ?", distance) }
  scope :within_area, ->(lat, lng, sw_lat, sw_lng, ne_lat, ne_lng) { where("latitude > ? AND latitude < ? AND longitude > ? AND longitude < ?", sw_lat, ne_lat, sw_lng, ne_lng) }
  scope :order_by_distance, ->(lat, lng) { select("*, distance_in_km(latitude, longitude, #{lat}, #{lng}) AS distance").order('distance') }

  def self.refresh_materialized
    ActiveRecord::Base.connection.execute "REFRESH MATERIALIZED VIEW materialized_aggregated_searches"
  end

  def self.search(params={})
    I18n.locale = params[:locale] if params[:locale]

    result = page(params[:page]).per(params[:per_page])

    if params[:query]
      # quick and dirty solution to find hospitals by department name
      if (hospital_ids = search_hospital_ids_by_department_name(params)).present?
        result.where!("entity_type = ? AND (hospital_id IN (?) OR content LIKE LOWER(?))", 'Hospital', hospital_ids, "%#{params[:query][:text]}%")
      else
        if params[:query][:text]
          words = Rseg.segment(params[:query][:text])
          words.each { |word| result = result.search_by_text(word) }
        end
        if params[:query][:type]
          result.where!(entity_type: params[:query][:type].split(',').map(&:strip))
        end
      end
      if params[:query][:hospital_id]
        result.where!(hospital_id: params[:query][:hospital_id])
      end
      if params[:query][:department_id]
        result.where!(department_id: params[:query][:department_id])
      end
      if params[:query][:physician_id]
        result.where!(physician_id: params[:query][:physician_id])
      end
      if params[:query][:medication_id]
        result.where!(medication_id: params[:query][:medication_id])
      end
      if params[:query][:speciality_id]
        result.where!(speciality_id: params[:query][:speciality_id])
      end
      if params[:query][:user_id]
        result.where!(user_id: params[:query][:user_id])
      end

      if params[:query][:area]
        area = params[:query][:area]
        result = result.within_area(area[:lat], area[:lng], area[:sw_lat], area[:sw_lng], area[:ne_lat], area[:ne_lng]).order_by_distance(area[:lat], area[:lng])
      end

      if params[:query][:nearby]
        nearby = params[:query][:nearby]
        result = result.nearby(nearby[:lat], nearby[:lng], nearby[:distance]).order_by_distance(nearby[:lat], nearby[:lng])
      end
    end

    if params[:sort]
      if params[:sort][:distance]
        distance = params[:sort][:distance]
        result = result.order_by_distance(distance[:lat], distance[:lng])
      end
      if params[:sort][:ranking]
        result.reorder!("active_reviews desc nulls last, avg_rating desc nulls last")
      end
      if params[:sort][:reviews_count]
        result.reorder!("reviews_count desc")
      end
      if params[:sort][:h_class]
        result.reorder!("h_class_order(h_class) desc")
      end
      if params[:sort][:created_at]
        result.reorder!("created_at desc")
      end
      if params[:sort][:content_length]
        result.reorder!("char_length(content) desc nulls last")
      end
    end

    result
  end

  protected

  def self.search_hospital_ids_by_department_name(params)
    if params[:query][:text].present? && params[:query][:type] == "Hospital"
      departments = search_by_text(params[:query][:text]).where(entity_type: 'Department').select(:searchable_id, :entity_type).map(&:searchable_entity)
      departments.map(&:hospital_ids).flatten.uniq
    end
  end

  def readonly?
    true
  end
end
