puts 'Create users '

GENDER = %w(male female unknown)
TRUE_OR_FALSE = %w(true false)
PATHWAY = %w(电视 网络 报纸)
OCCUPATION = %w(医生 软件工程师 销售 记者)
COUNTRY = %w(美国 英国 中国 日本)
CITY = %w(上海 武汉 伦敦 巴黎)
INCOME_LEVEL = %w(5000以下 5000至10000 10000以上 10000至15000 15000以上)
INTERESTS = %w(篮球 羽毛球 滑冰 棒球)
CONDITIONS = Condition.pluck(:id)

PHONECN_PREFIX = %w(130 131 132 134 135 136 137 138 139 150 151 157 158 159 187 188 130 131 132 155 156 185 186 133 153 180 189)

100.times do |i|
  user = User.where(email: "user#{i}@ekohe.com").first_or_initialize(
    phone: PHONECN_PREFIX.sample + "#{i}8888888".to(7),
    password: '111111',
    skip_confirmation: true
  )
  if user.new_record?
    user.confirm
    user.save!(validate: false)
    user.reload
    user.profile.update(
      gender: GENDER.sample,
      birthdate: Date.today - [20,13,34].sample.year,
      height: [0.5, 1, 1.5, 1.4, 1.76, 1.87, 2.26, 3].sample,
      weight: (1..650).to_a.sample,
      pathway: PATHWAY.sample,
      occupation: OCCUPATION.sample,
      country: COUNTRY.sample,
      city: CITY.sample,
      network_visible: TRUE_OR_FALSE.sample,
      income_level: INCOME_LEVEL.sample,
      interests: INTERESTS.sample,
      condition_ids: CONDITIONS.sample(2),
      network_visible: TRUE_OR_FALSE.sample
    )
    printf '.'
  end
end

puts ''

