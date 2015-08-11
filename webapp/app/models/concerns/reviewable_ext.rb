module ReviewableExt
  extend ActiveSupport::Concern

  attr_accessor :reviews_count

  def reviews_count
    @reviews_count || self[:reviews_count]
  end

  included do
    class_attribute :review_count_sql
    self.review_count_sql = %{(SELECT COUNT(*) FROM "reviews" WHERE "reviews"."type" IN ('#{self.name}Review') AND "reviews"."status" = 'published' AND "reviews"."reviewable_id" = #{self.table_name}.id) AS reviews_count}

    has_many :reviews, ->(reviewable) { where(type: reviewable.class.name + 'Review') },
      foreign_key: 'reviewable_id', dependent: :destroy
  end

end
