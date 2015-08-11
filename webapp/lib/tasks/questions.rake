namespace :questions do
  desc 'merge and rename criteria'
  task :merge_and_rename => :environment do
    def merge_and_rename_question(options = {})
      from_names = options.delete(:from_names)
      question_from = Question.find_by(category: options[:category], content: from_names[0])
      from_names[1..-1].each do |from_name|
        question = Question.find_by(category: options[:category], content: from_name)
        question.answers.update_all(question_id: question_from.id)
        question.destroy
      end
      options[:from_name] = from_names[0]
      rename_question(options)
    end

    def rename_question(options = {})
      question = Question.find_by(category: options[:category], content: options[:from_name])
      I18n.locale = 'en'
      question.content = options[:to_english_name]
      question.save
      I18n.locale = 'zh-CN'
      question.content = options[:to_chinese_name]
      question.save
    end

    I18n.locale = 'zh-CN'

    merge_and_rename_question(category: 'hospital', from_names: ['设施齐全', '现代程度'], to_chinese_name: '公共设施', to_english_name: 'infrastructure')
    rename_question(category: 'hospital', from_name: '服务态度', to_chinese_name: '服务态度', to_english_name: 'staff attitude')
    merge_and_rename_question(category: 'hospital', from_names: ['预约服务', '服务范围'], to_chinese_name: '挂号预约', to_english_name: 'register & appointment')
    merge_and_rename_question(category: 'hospital', from_names: ['卫生情况', '环境舒适'], to_chinese_name: '卫生环境', to_english_name: 'environment hygiene')

    rename_question(category: 'physician', from_name: '治疗效果明显', to_chinese_name: '疗程效果', to_english_name: 'disease management')
    merge_and_rename_question(category: 'physician', from_names: ['尊重患者意见', '态度友好'], to_chinese_name: '服务态度', to_english_name: 'bedside manner')
    merge_and_rename_question(category: 'physician', from_names: ['检查认真彻底', '提供必要诊疗', '听取患者叙述', '解释清楚准确'], to_chinese_name: '问诊服务', to_english_name: 'inquiry service')

    rename_question(category: 'medication', from_name: '药效明显', to_chinese_name: '药物效果', to_english_name: 'efficacy')
    rename_question(category: 'medication', from_name: '副作用', to_chinese_name: '无副作用', to_english_name: 'tolerance')
    rename_question(category: 'medication', from_name: '使用方便', to_chinese_name: '使用途径', to_english_name: 'ease of use')
  end

  desc 'add clinic date and time'
  task :add_clinic_date_and_time => :environment do
    I18n.locale = 'en'
    question = Question.create content: 'clinic date', category: 'hospital', question_type: 'clinic_time', position: 11
    I18n.locale = 'zh-CN'
    question.update content: '就诊日期'
    I18n.locale = 'en'
    question = Question.create content: 'clinic time', category: 'hospital', question_type: 'clinic_time', position: 12
    I18n.locale = 'zh-CN'
    question.update content: '就诊时间'

    I18n.locale = 'en'
    question = Question.create content: 'clinic date', category: 'physician', question_type: 'clinic_time', position: 21
    I18n.locale = 'zh-CN'
    question.update content: '就诊日期'
    I18n.locale = 'en'
    question = Question.create content: 'clinic time', category: 'physician', question_type: 'clinic_time', position: 22
    I18n.locale = 'zh-CN'
    question.update content: '就诊时间'
  end
end
