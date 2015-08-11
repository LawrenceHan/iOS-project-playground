# Check note or content by blacklist, and set status after checking.
module BlacklistChecking
  extend ActiveSupport::Concern

  included do
    before_save :blacklist_checking
  end

  def need_audit?
    self.status == 'pending'
  end

  def human_status_class
    case status
    when 'pending'             then 'danger'
    when 'rejected'            then 'default'
    when 'unread', 'published' then 'success'
    else                            'primary'
    end
  end

  def human_status
    %~<span class="label label-#{human_status_class}">#{I18n.t("status.#{self.status}")}</span>~.html_safe
  end

  def harmony_content
    clean_text = Blacklist.clean_up(read_attribute(checked_column))
    self.send("#{checked_column}=", clean_text)
  end

  def checked_column
    (%w(note content) & attribute_names).first
  end

  def has_black_word?
    Blacklist.has_black_word?(read_attribute(checked_column))
  end

  private
  def blacklist_checking
    return true unless checked_column
    if has_black_word?
      clean_text = Blacklist.clean_up(read_attribute(checked_column))
      self.send("#{checked_column}=", clean_text)
    # else
    #   self.status = self.class::VALID_STATUS
    end
  end

end
