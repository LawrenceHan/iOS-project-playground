module Localeable
  def switch_locale(locale)
    current_locale = I18n.locale
    begin
      I18n.locale = locale
      yield
    ensure
      I18n.locale = current_locale
    end
  end
end
