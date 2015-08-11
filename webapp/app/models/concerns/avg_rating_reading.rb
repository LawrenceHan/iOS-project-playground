module AvgRatingReading
  extend ActiveSupport::Concern

  def avg_rating
    read_attribute(:avg_rating).to_f.round(1)
  end
end
