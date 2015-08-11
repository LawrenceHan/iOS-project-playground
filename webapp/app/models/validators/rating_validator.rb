class RatingValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute, (options[:message] || "must in 0..5") unless
      value.blank? || (0..5).include?(value)
  end
end
