module CompletionReading
  extend ActiveSupport::Concern

  def completion
    read_attribute(:completion).to_f.round(2)
  end
end
