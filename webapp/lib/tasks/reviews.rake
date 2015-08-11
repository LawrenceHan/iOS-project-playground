namespace :reviews do
  desc 'export hospital'
  task :export_hospital, [:hospital_id] => :environment do |task, args|
    hospital = Hospital.find args.hospital_id

    I18n.locale = 'zh-CN'
    print hospital.name
    I18n.locale = 'en-US'
    puts " (#{hospital.name})"
    I18n.locale = 'zh-CN'
    hospital.answers.group_by(&:question).each do |question, answers|
      I18n.locale = 'zh-CN'
      print question.content
      if question.content == '等待用时'
        I18n.locale = 'en-US'
        puts " (#{question.content})," +
          Question::WAITING_TIME_OPTIONS.map(&:last).map { |i| "#{i} (#{answers.select { |answer| answer.waiting_time == i }.size})" }.join(",") +
          ",#{answers.map(&:waiting_time).sum * 1.0 / answers.size} (#{answers.size})"
      else
        I18n.locale = 'en-US'
        puts " (#{question.content})," +
          (1..5).map { |i| "#{i} (#{answers.select { |answer| answer.rating == i }.size})" }.join(",") +
          ",#{answers.map(&:rating).sum * 1.0 / answers.size} (#{answers.size})"
      end
    end; nil
  end

  desc "export hospital's physicians"
  task :export_physicians, [:hospital_id] => :environment do |task, args|
    I18n.locale = 'zh-CN'
    hospital = Hospital.find args.hospital_id

    hospital.physicians.each do |physician|
      if physician.answers.size > 0
        I18n.locale = 'zh-CN'
        print physician.name
        I18n.locale = 'en-US'
        puts " (#{physician.name})"
        I18n.locale = 'zh-CN'
        physician.answers.group_by(&:question).each do |question, answers|
          I18n.locale = 'zh-CN'
          print question.content
          if question.content == '问诊效率'
            I18n.locale = 'en-US'
            puts " (#{question.content})," +
              Question::WAITING_TIME_OPTIONS.map(&:last).map { |i| "#{i} (#{answers.select { |answer| answer.waiting_time == i }.size})" }.join(",") +
              ",#{answers.map(&:waiting_time).sum * 1.0 / answers.size} (#{answers.size})"
          else
            I18n.locale = 'en-US'
            puts " (#{question.content})," +
              (1..5).map { |i| "#{i} (#{answers.select { |answer| answer.rating == i }.size})" }.join(",") +
              ",#{answers.map(&:rating).sum * 1.0 / answers.size} (#{answers.size})"
          end
        end; nil
      end
    end
  end

  desc 'fix empty ratings'
  task :fix_empty_ratings => :environment do
    Review.find_each do |review|
      answers = review.answers
      if answers.any? { |a| a.rating == 0 }
        sum = answers.select { |a| a.rating > 0 }.inject(0) { |sum, a| sum += a.rating }
        count = answers.select { |a| a.rating > 0 }.count
        answers.select { |a| a.rating == 0 }.each { |a| a.update_attribute :rating, (sum * 1.0 / count).ceil }
      end
    end
  end
end
