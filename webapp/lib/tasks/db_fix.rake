namespace :db_fix do

  namespace :hospital do
    desc 'replace every arabic number to chinese number'
    task :name => :environment do
      Hospital.where("name ~ '第\\d'").each do |h|
        h.name = h.name.gsub(/第\d+/, '第1' => '第一', '第8' => '第八', '第2' => '第二', '第9' => '第九', '第85' => '第八五', '第455' => '第四五五', '第10' => '第十', '第411' => '第四一一', '第6' => '第六', '第3' => '第三', '第7' => '第七', '第5' => '第五')
        h.save!(validate: false)
      end
    end
  end

  namespace :review do
    desc 'Change status for old review'
    task :status => :environment do
      Review.where('avg_rating < 2.0').update_all(status: 'pending')
      Review.where('avg_rating >= 2.0').update_all(status: 'published')
    end
  end

  namespace :physicians do
    task :fix_wrong_birthdate => :environment do
      MINIMUM_AGE = 2
      puts "Currently having #{Physician.where(["birthdate IS NOT NULL"]).count} physicians less than #{MINIMUM_AGE} years old."
      Physician.where(["birthdate > ?", MINIMUM_AGE.years.ago]).update_all("birthdate = NULL")
      puts "Now having #{Physician.where(["birthdate IS NOT NULL"]).count} physicians less than #{MINIMUM_AGE} years old."
    end
  end
end
