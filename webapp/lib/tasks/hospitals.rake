namespace :db do
  namespace :hospitals do
    desc 'Merge hospital A into hospital B'
    task :merge, [:hospital_a_id, :hospital_b_id] => :environment do |t, args|
      begin
        Hospital.find(args[:hospital_a_id]).merge_into!(Hospital.find(args[:hospital_b_id]))
      rescue ActiveRecord::RecordNotFound => e
        puts "Error, could not find hospital: #{e.inspect}"
      end
    end

    desc 'update from gbi'
    task :from_gbi => :environment do
      docs = File.read(Rails.root.join('spec/tasks/gbi_hospitals.csv'))
      CSV.parse(docs, headers: true) do |row|
        if row['operation'] == '√'
          hospital = Hospital.find row['ID']
          hospital.name = row['name'] if row['name'].present?
          hospital.official_name = row['official_name'] if row['official_name'].present?
          hospital.website = row['OFFICIAL_WEBSITE'] if row['OFFICIAL_WEBSITE'].present?
          hospital.phone = row['phone'] if row['phone'].present?
          hospital.district = row['DISTRICT'] if row['DISTRICT'].present?
          hospital.address = row['address'] if row['address'].present?
          hospital.post_code = row['post_code'] if row['post_code'].present?
          hospital.h_class = row['h_class'] if row['h_class'].present?
          hospital.latitude = row['latitude'] if row['latitude'].present?
          hospital.longitude = row['longitude'] if row['longitude'].present?
          hospital.city = row['city'] if row['city'].present?
          hospital.save
        end
      end
    end

    desc 'merge hospitals based on gbi'
    task :merge_gbi_hospitals => :environment do
      def merge_hospital(from_id, to_id)
        hospital = Hospital.find from_id
        another_hospital = Hospital.find to_id
        hospital.merge_into! another_hospital
      end
      merge_hospital(1, 746)
      merge_hospital(2, 747)
      merge_hospital(3, 783)
      merge_hospital(4, 954)
      merge_hospital(5, 773)
      merge_hospital(6, 775)
      merge_hospital(8, 752)
      merge_hospital(10, 819)
      merge_hospital(11, 994)
      merge_hospital(12, 986)
      merge_hospital(14, 667)
      merge_hospital(15, 774)
      merge_hospital(18, 771)
      merge_hospital(19, 772)
      merge_hospital(20, 812)
      merge_hospital(22, 992)
      merge_hospital(23, 1002)
      merge_hospital(24, 744)
      merge_hospital(27, 757)
      merge_hospital(28, 789)
      merge_hospital(29, 989)
      merge_hospital(32, 756)
      merge_hospital(33, 758)
      merge_hospital(34, 1000)
      merge_hospital(35, 755)
      merge_hospital(37, 760)
      merge_hospital(38, 777)
      merge_hospital(41, 762)
      merge_hospital(43, 946)
      merge_hospital(47, 999)
      merge_hospital(49, 995)
      merge_hospital(51, 751)
      merge_hospital(54, 50)
      merge_hospital(55, 953)
      merge_hospital(56, 750)
      merge_hospital(57, 748)
      merge_hospital(58, 749)
      merge_hospital(60, 1001)
      merge_hospital(62, 753)
      merge_hospital(63, 981)
      merge_hospital(64, 991)
      merge_hospital(68, 993)
      merge_hospital(69, 790)
      merge_hospital(70, 767)
      merge_hospital(71, 768)
      merge_hospital(72, 769)
      merge_hospital(74, 785)
      merge_hospital(75, 759)
      merge_hospital(77, 791)
      merge_hospital(78, 765)
      merge_hospital(79, 764)
      merge_hospital(84, 782)
      merge_hospital(93, 784)
      merge_hospital(99, 988)
      merge_hospital(100, 741)
      merge_hospital(109, 793)
      merge_hospital(111, 778)
      merge_hospital(112, 778)
      merge_hospital(119, 846)
      merge_hospital(121, 846)
      merge_hospital(127, 969)
      merge_hospital(131, 328)
      merge_hospital(133, 804)
      merge_hospital(135, 803)
      merge_hospital(136, 821)
      merge_hospital(137, 787)
      merge_hospital(141, 805)
      merge_hospital(142, 947)
      merge_hospital(144, 788)
      merge_hospital(146, 795)
      merge_hospital(152, 153)
      merge_hospital(158, 814)
      merge_hospital(159, 900)
      merge_hospital(160, 1013)
      merge_hospital(163, 800)
      merge_hospital(168, 796)
      merge_hospital(173, 813)
      merge_hospital(175, 780)
      merge_hospital(176, 822)
      merge_hospital(184, 786)
      merge_hospital(189, 990)
      merge_hospital(190, 779)
      merge_hospital(192, 191)
      merge_hospital(193, 781)
      merge_hospital(194, 996)
      merge_hospital(197, 776)
      merge_hospital(199, 873)
      merge_hospital(209, 1011)
      merge_hospital(212, 864)
      merge_hospital(219, 841)
      merge_hospital(231, 751)
      merge_hospital(236, 924)
      merge_hospital(239, 920)
      merge_hospital(241, 859)
      merge_hospital(246, 728)
      merge_hospital(249, 851)
      merge_hospital(250, 849)
      merge_hospital(276, 669)
      merge_hospital(283, 984)
      merge_hospital(291, 862)
      merge_hospital(296, 833)
      merge_hospital(311, 977)
      merge_hospital(312, 839)
      merge_hospital(315, 817)
      merge_hospital(316, 850)
      merge_hospital(318, 858)
      merge_hospital(320, 903)
      merge_hospital(323, 321)
      merge_hospital(341, 916)
      merge_hospital(345, 915)
      merge_hospital(352, 980)
      merge_hospital(353, 834)
      merge_hospital(354, 741)
      merge_hospital(368, 914)
      merge_hospital(370, 870)
      merge_hospital(372, 950)
      merge_hospital(373, 911)
      merge_hospital(374, 848)
      merge_hospital(376, 885)
      merge_hospital(377, 892)
      merge_hospital(388, 874)
      merge_hospital(391, 861)
      merge_hospital(395, 961)
      merge_hospital(397, 961)
      merge_hospital(401, 838)
      merge_hospital(403, 402)
      merge_hospital(411, 869)
      merge_hospital(415, 865)
      merge_hospital(417, 866)
      merge_hospital(419, 879)
      merge_hospital(421, 882)
      merge_hospital(424, 867)
      merge_hospital(425, 863)
      merge_hospital(427, 878)
      merge_hospital(429, 1010)
      merge_hospital(431, 944)
      merge_hospital(435, 346)
      merge_hospital(436, 807)
      merge_hospital(444, 985)
      merge_hospital(452, 921)
      merge_hospital(454, 825)
      merge_hospital(458, 919)
      merge_hospital(463, 932)
      merge_hospital(468, 913)
      merge_hospital(471, 823)
      merge_hospital(474, 828)
      merge_hospital(475, 242)
      merge_hospital(487, 951)
      merge_hospital(521, 742)
      merge_hospital(532, 911)
      merge_hospital(533, 905)
      merge_hospital(534, 917)
      merge_hospital(538, 909)
      merge_hospital(540, 910)
      merge_hospital(541, 912)
      merge_hospital(544, 974)
      merge_hospital(547, 945)
      merge_hospital(548, 881)
      merge_hospital(550, 978)
      merge_hospital(551, 847)
      merge_hospital(543, 46)
      merge_hospital(561, 234)
      merge_hospital(564, 438)
      merge_hospital(565, 148)
      merge_hospital(569, 379)
      merge_hospital(571, 877)
      merge_hospital(575, 928)
      merge_hospital(580, 890)
      merge_hospital(583, 581)
      merge_hospital(584, 888)
      merge_hospital(593, 860)
      merge_hospital(595, 880)
      merge_hospital(596, 885)
      merge_hospital(597, 739)
      merge_hospital(599, 923)
      merge_hospital(600, 923)
      merge_hospital(615, 234)
      merge_hospital(622, 624)
      merge_hospital(623, 624)
      merge_hospital(633, 907)
      merge_hospital(640, 842)
      merge_hospital(643, 920)
      merge_hospital(646, 384)
      merge_hospital(653, 748)
      merge_hospital(659, 648)
      merge_hospital(660, 188)
      merge_hospital(661, 39)
      merge_hospital(663, 751)
      merge_hospital(665, 664)
      merge_hospital(678, 766)
      merge_hospital(679, 770)
      merge_hospital(854, 741)
      merge_hospital(893, 894)
      merge_hospital(916, 725)
      merge_hospital(987, 728)
    end

    desc 'add foreign hospitals'
    task :add_foreign_hospitals => :environment do
      docs = File.read(Rails.root.join('spec/tasks/foreign_hospitals_to_add.csv'))
      CSV.parse(docs, headers: true) do |row|
        I18n.locale = 'en'
        hospital = Hospital.new
        hospital.name = row['nom']
        hospital.official_name = row['nom']
        hospital.address = row['adresse']
        hospital.description = row['descr_en']
        hospital.save
        I18n.locale = 'zh-CN'
        hospital.name = row['nom_zh']
        hospital.official_name = row['nom_zh']
        hospital.address = row['adresse_zh']
        hospital.city = row['ville_zh']
        hospital.post_code = row['cp']
        hospital.latitude = row['latitude']
        hospital.longitude = row['longitude']
        hospital.description = row['descr_zh']
        hospital.phone = row['enum( tel (lang']
        hospital.save
      end
    end

    desc 'sync hospitals'
    task :sync_hospitals => :environment do
      docs = File.read(Rails.root.join('spec/tasks/hospitals.csv'))
      CSV.parse(docs, headers: true) do |row|
        hospital = Hospital.find_by(name: row['nom_zh']) || Hospital.new
        I18n.locale = 'en'
        hospital.name = row['nom']
        hospital.official_name = row['nom']
        hospital.address = row['adresse']
        hospital.description = row['descr_en']
        hospital.save
        I18n.locale = 'zh-CN'
        hospital.name = row['nom_zh']
        hospital.official_name = row['nom_zh']
        hospital.address = row['adresse_zh']
        hospital.city = row['ville_zh']
        hospital.post_code = row['cp']
        hospital.latitude = row['latitude']
        hospital.longitude = row['longitude']
        hospital.description = row['descr_zh']
        hospital.phone = row['enum( tel (lang']
        hospital.save
      end
    end

    desc 'update hospitals edition 2'
    task :update_hospitals_edition_2 => :environment do
      docs = File.read(Rails.root.join('spec/tasks/hospitals_edition_2.csv'))
      CSV.parse(docs, headers: true) do |row|
        begin
          hospital = Hospital.find row['id']
          hospital.address = row['address'] if row['address'].present?
          hospital.phone = row['phone'] if row['phone'].present?
          hospital.post_code = row['post_code'] if row['post_code'].present?
          if row['h_class'].present?
            if row['h_class'] == '私立'
              hospital.h_class = '未评定'
              hospital.private_owned!
            else
              hospital.h_class = row['h_class']
            end
          end
          hospital.website = row['website'] if row['website'].present?
          hospital.city = row['city'] if row['city'].present?
          hospital.district = row['district'] if row['district'].present?
          hospital.save
        rescue ActiveRecord::RecordNotFound
        end
      end
    end

    desc 'mark hospitals as private'
    task :mark_as_private => :environment do
      docs = File.read(Rails.root.join('spec/tasks/private_hospitals.csv'))
      CSV.parse(docs, headers: true) do |row|
        if row['Grade'] == 'Private'
          Hospital.find(row['id']).private_owned!
        end
      end
    end
  end
end
