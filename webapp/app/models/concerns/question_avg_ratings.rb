module QuestionAvgRatings
  extend ActiveSupport::Concern

  included do
    has_many :answers, through: "#{self.model_name.singular}_reviews".to_sym
  end

  def question_avg_ratings
    Question.with_category(self.class.model_name.singular).ratings.order("position ASC").map do |x|
      avg_rating = self.answers.joins(:review).where('question_id = ?', x.id).where('reviews.status = ?', 'published').average(:rating).to_f
      x.as_json(only: [:id, :content]).merge(avg_rating: avg_rating)
    end
  end
end
