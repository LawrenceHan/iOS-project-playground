module I18n
  POSSIBLE_LOCALES = {
    'en' => %w(en),
    'en-US' => %w(en-US en),
    'zh' => %w(zh),
    'zh-CN' => %w(zh-CN zh)
  }

  def possible_locales(locale)
    POSSIBLE_LOCALES[locale.to_s]
  end

  extend self
end
