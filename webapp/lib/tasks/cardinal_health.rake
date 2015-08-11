namespace :cardinal_health do
  desc "import cardinal health data from file on Google drive"
  task :import, [:file_path] => :environment do |task, args|
    result = File.read(args.file_path)
    drugs = []
    CSV.parse(result, headers: :true) do |row|
      CardinalHealth.create(row.to_hash.except!("tcv_id"))
    end
    CardinalHealth.all.each do|x|
      medication = nil
      if (res = Medication.where("name LIKE ? AND name LIKE ? AND name LIKE ?",
                                        "%#{x.official_name}%",
                                        "%#{x.common_name}%",
                                        "%#{x.size}%")).count > 0
        medication = res[0]
      elsif (res = Medication.where("name LIKE ? AND name LIKE ?",
                                        "%#{x.official_name}%",
                                        "%#{x.size}%")).count > 0
        medication = res[0]
      else (res = Medication.where("name LIKE ?", "%#{x.official_name}%")).count > 0
        medication = res[0]
      end
      medication.cardinal_health = x if medication
    end

  end
end
