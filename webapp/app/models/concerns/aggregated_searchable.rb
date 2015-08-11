module AggregatedSearchable

  extend ActiveSupport::Concern

  attr_accessor :distance, :avg_rating, :reviews_count

  def distance
    # @distance is assigned by AggregatedSearch in v2 search api, see app/api/v2/search.rb
    # self[:distance] is fetched from Hospital in v1 search api.
    @distance || self[:distance]
  end

  def avg_rating
    # @avg_rating is assigned by AggregatedSearch in v2 search api, see app/api/v2/search.rb
    # self[:avg_rating] is fetched from Hospital/Physician/Medication in v1 search api.
    (@avg_rating || self[:avg_rating]).to_f.round(1)
  end

  def reviews_count
    # @reviews_count is assigned by AggregatedSearch in v2 search api, see app/api/v2/search.rb
    # self[:reviews_count] is fetched from Hospital/Physician/Medication in v1 search api.
    @reviews_count || self[:reviews_count]
  end

  def human_distance
    distance < 1 ? "#{(distance.round(4) * 1000).to_i}#{I18n.t('word.m')}" : "#{distance.round(2)}#{I18n.t('word.km')}"
  rescue
    ''
  end

end
