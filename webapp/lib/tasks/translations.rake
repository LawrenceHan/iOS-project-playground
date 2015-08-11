require 'csv'

namespace :db do
  namespace :translations do
    desc 'Import english translations from yaml files'
    task :init_en => :environment do
      I18n.locale = 'en'
      { Hospital: %w(name official_name address),
        Department: %w(name),
        Physician: %w(name),
        HealthCondition: %w(name category),
        Medication: %w(name),
        Speciality: %w(name),
        Question: %w(content) }.each do |model, fields|
        puts "Translating #{model}"
        model.to_s.constantize.find_each do |record|
          fields.each do |field|
            begin
              en_field = I18n.t(record.send(field))
              if en_field !~ /translation missing/
                record.send "#{field}=", en_field
              end
            rescue I18n::ArgumentError
            end
          end
          record.save
        end
        puts "Translated: #{model}"
      end
    end

    desc 'Translate doctor names by pinyin'
    task :doctor_names_pinyin => :environment do
      I18n.locale = 'zh-CN'
      Physician.find_each do |physician|
        physician.translate_to_pinyin
      end
    end
  end
end
