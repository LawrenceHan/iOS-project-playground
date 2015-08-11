class Blacklist < ActiveRecord::Base
  validates :word, presence: true, uniqueness: true
  HIGHLIGHT_WRAPPER_PREFIX = '<span class="label label-danger">'
  HIGHLIGHT_WRAPPER_SUFFIX = '</span>'
  HIGHLIGHT_WRAPPER_PATTERN = HIGHLIGHT_WRAPPER_PREFIX + '\k<word>' + HIGHLIGHT_WRAPPER_SUFFIX
  WORD_REPLACEMENT = '*'

  def self.regexp_safe_words
    @regexp_safe_words ||= "(?<word>#{pluck(:word).map{|x| Regexp.escape(x) }.join('|')})"
  end

  def self.black_regexp
    Regexp.new("(#{HIGHLIGHT_WRAPPER_PREFIX})?#{regexp_safe_words}(#{HIGHLIGHT_WRAPPER_SUFFIX})?", true)
  end

  def self.has_black_word?(text)
    return false if text.blank?
    !!(text.to_s.force_encoding(Encoding::UTF_8) =~ black_regexp)
  end

  def self.highlight_black_word(text)
    text.to_s.force_encoding(Encoding::UTF_8).gsub(black_regexp, HIGHLIGHT_WRAPPER_PATTERN)
  end

  def self.clean_up(text)
    clean_content = count.zero? ? text.to_s : text.to_s.force_encoding(Encoding::UTF_8).gsub(black_regexp, WORD_REPLACEMENT)
    ActionController::Base.helpers.sanitize(clean_content, tags: [])
  end
end

# == Schema Information
#
# Table name: blacklists
#
#  id         :integer          not null, primary key
#  word       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

