module AdminPanel::ReviewHelper
  def avg_ratings_preview(question_avg_ratings)
    question_avg_ratings.map { |content, value| "#{content}(#{value})" }.join(',')
  end
end
