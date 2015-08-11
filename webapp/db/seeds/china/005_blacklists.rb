puts "Create blacklists "

BLACKLIST_WORDS = %w(
  fuck
  shit
  dick
  操
  江泽民
  胡锦涛
  共产党
  胡萝卜　
  天安门
  暴行
  暴动
  法轮功
  大规模　
  革命　　
  民主　　
  殖民主义
  物价飞涨
  房价飙升
  政府　　
  政权　　
  腐败　　
  失业率　
  自由
  妈的
  狗日的
  他娘的
)

BLACKLIST_WORDS.each do |x|
  Blacklist.where(word: x).first_or_create
  printf '.'
end

puts ''
