class HealthCondition < ActiveRecord::Base
  translates :name, :category, fallbacks_for_empty_translations: true

  include AggregatedSearchable

  validates :name, presence: true, uniqueness: true

  def as_json(opts={})
    super({only: [:id, :name, :type]}.merge(opts))
  end

  def searchable_json
    as_json(only: [:id, :name, :type], method: [:class_name])
  end

  def self.list_matched_by_name(name)
    data = []
    # FIXME: globalize doesn't work well with LIKE
    list = with_translations(I18n.possible_locales(I18n.locale)).where("LOWER(health_condition_translations.name) LIKE ?", "%#{name.downcase}%")

    list.group_by(&:category).each do |category, lists|
      data << { name: category, objects: lists }
    end
    data
  end
end

# == Schema Information
#
# Table name: health_conditions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  category   :string(255)
#  type       :string(30)
#

