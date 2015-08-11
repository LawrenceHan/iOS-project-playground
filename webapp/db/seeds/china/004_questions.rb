puts 'Creating questions '

# Hospital
%w(设施齐全 卫生情况 预约服务).each do |content|
  Question.where(category: 'hospital', content: content).first_or_create(question_type: 'rating')
  printf '.'
end

%w(等待时间).each do |content|
  options = [["无需等待", 0], ["5分钟", 5], ["10分钟", 10], ["15分钟", 15],
             ["30分钟", 30], ["45分钟", 45], ["1小时", 60], ["1小时15分钟", 75],
             ["1小时30分钟", 90], ["1小时45分钟", 105], ["2小时", 120], ["2小时30分钟", 150],
             ["3小时", 180], ["3小时30分钟", 210], ["4小时或更多", 240]]
  Question.where(category: 'hospital', content: content).first_or_create(
    question_type: 'waiting_time', options: options)
  printf '.'
end

%w(现代程度 环境舒适 服务范围 服务态度).each do |content|
  Question.where(category: 'hospital', content: content).first_or_create(question_type: 'rating')
  printf '.'
end



# Physician
%w(解释清楚准确 听取患者叙述 检查认真彻底 提供必要诊疗 治疗效果明显).each do |content|
  Question.where(category: 'physician', content: content).first_or_create(question_type: 'rating')
  printf '.'
end

%w(态度友好 尊重患者意见 跟踪服务).each do |content|
  Question.where(category: 'physician', content: content).first_or_create(question_type: 'rating')
  printf '.'
end

%w(问诊效率).each do |content|
  options = [["5分钟", 5], ["10分钟", 10], ["15分钟", 15], ["20分钟", 20],
             ["30分钟", 30], ["45分钟", 45], ["1小时", 60], ["1小时15分钟", 75],
             ["1小时30分钟", 90], ["1小时30分钟或更多", 120]]
  Question.where(category: 'physician', content: content).first_or_create(
    question_type: 'waiting_time', options: options)
  printf '.'
end

%w(问诊费用).each do |content|
  Question.where(category: 'physician', content: content).first_or_create(question_type: 'price')
  printf '.'
end



# Medication
%w(药效明显 使用方便 副作用 药物价格).each do |content|
  Question.where(category: 'medication', content: content).first_or_create(question_type: 'rating')
  printf '.'
end

# %w(治疗时间).each do |content|
#   Question.where(category: 'medication', content: content).first_or_create(question_type: 'rating')
#   printf '.'
# end

puts ''
