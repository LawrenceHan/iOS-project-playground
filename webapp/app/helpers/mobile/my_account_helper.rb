module Mobile
  module MyAccountHelper
    OPTIONS = {
      occupation: ['Administration', 'Accounting', 'Business', 'Construction and trade', 'Consulting', 'Customer service', 'Educational', 'Engineering', 'Farming ', 'Healthcare', 'Homemaker', 'Law', 'Tourism'],
      occupation_cn: ['专业人员','高级行政管理（董事长/总经理/行政总裁）','经理','老板/合伙人/自雇','白领','政府人员/机关干部','蓝领','技术人员','家庭主妇','退休','学生','失业/待业','自由职业者','其它（请注明）', '拒答（不出示）'],
      education_level: ['10+2', 'B.Sc.', 'B.A.', 'B.Com.', 'B.Tech.', 'B.B.A.', 'B.C.A.', 'B.D.S.', 'LL.B.', 'LL.M.', 'M.B.B.S.', 'M.Sc.', 'M.A.', 'M.Com.', 'M.Tech.', 'M.B.A.', 'M.C.A.', 'M.D.S.', 'M.D.', 'P.H.D.'],
      education_level_cn: ['高中','大专','大学本科','硕士','博士'],
      income_level: ['less than 20,000 INR / month', '20,000 - 60,000 INR / month', 'more than 60,000 INR / month'],
      income_level_cn: ['5000 以下','5000 至 10000','10000 至 20000','20000 至 35000','35000 至 50000','50000 以上'],
      birthplace: {
        'JAMMU & KASHMIR' => ['Kupwara', 'Badgam', 'Leh(Ladakh)', 'Kargil', 'Punch', 'Rajouri', 'Kathua', 'Baramula', 'Bandipore', 'Srinagar', 'Ganderbal', 'Pulwama', 'Shupiyan', 'Anantnag', 'Kulgam', 'Doda', 'Ramban', 'Kishtwar', 'Udhampur', 'Reasi', 'Jammu', 'Samba'],
        'HIMACHAL PRADESH' => ['Chamba', 'Kangra', 'Lahul & Spiti', 'Kullu', 'Mandi', 'Hamirpur', 'Una', 'Bilaspur', 'Solan', 'Sirmaur', 'Shimla', 'Kinnaur'],
        'PUNJAB' => ['Gurdaspur', 'Kapurthala ', 'Jalandhar', 'Hoshiarpur', 'Shahid Bhagat Singh Nagar ', 'Fatehgarh Sahib', 'Ludhiana', 'Moga', 'Firozpur', 'Muktsar', 'Faridkot', 'Bathinda', 'Mansa', 'Patiala', 'Amritsar ', 'Tarn Taran', 'Rupnagar', 'Sahibzada Ajit Singh Nagar', 'Sangrur', 'Barnala'],
        'CHANDIGARH' => ['Chandigarh'],
        'UTTARAKHAND' => ['Uttarkashi', 'Chamoli', 'Rudraprayag', 'Tehri Garhwal', 'Dehradun', 'Garhwal', 'Pithoragarh', 'Bageshwar', 'Almora', 'Champawat', 'Nainital', 'Udham Singh Nagar', 'Hardwar'],
        'HARYANA' => ['Panchkula', 'Ambala', 'Yamunanagar', 'Kurukshetra', 'Kaithal', 'Karnal', 'Panipat', 'Sonipat', 'Jind', 'Fatehabad', 'Sirsa', 'Hisar', 'Bhiwani', 'Rohtak', 'Jhajjar', 'Mahendragarh', 'Rewari', 'Gurgaon', 'Mewat', 'Faridabad', 'Palwal'],
        'NCT OF DELHI' => ['North West', 'North', 'North East', 'East', 'New Delhi', 'Central', 'West', 'South West', 'South'],
        'RAJASTHAN' => ['Ganganagar', 'Hanumangarh', 'Bikaner', 'Churu', 'Jhunjhunun', 'Alwar', 'Bharatpur', 'Dhaulpur', 'Karauli', 'Sawai Madhopur', 'Dausa', 'Jaipur', 'Sikar', 'Nagaur', 'Jodhpur', 'Jaisalmer', 'Barmer', 'Jalor', 'Sirohi', 'Pali', 'Ajmer', 'Tonk', 'Bundi', 'Bhilwara', 'Rajsamand', 'Dungarpur', 'Banswara', 'Chittaurgarh', 'Kota', 'Baran', 'Jhalawar', 'Udaipur', 'Pratapgarh'],
        'UTTAR PRADESH' => ['Saharanpur', 'Muzaffarnagar', 'Bijnor', 'Moradabad', 'Rampur', 'Jyotiba Phule Nagar', 'Meerut', 'Baghpat', 'Ghaziabad', 'Gautam Buddha Nagar', 'Bulandshahr', 'Aligarh', 'Mahamaya Nagar', 'Mathura', 'Agra', 'Firozabad', 'Mainpuri', 'Budaun', 'Bareilly', 'Pilibhit', 'Shahjahanpur', 'Kheri', 'Sitapur', 'Hardoi', 'Unnao', 'Lucknow', 'Rae Bareli', 'Farrukhabad', 'Kannauj', 'Etawah', 'Auraiya', 'Kanpur Dehat', 'Kanpur Nagar', 'Jalaun', 'Jhansi', 'Lalitpur', 'Hamirpur', 'Mahoba', 'Banda', 'Chitrakoot', 'Fatehpur', 'Pratapgarh', 'Kaushambi', 'Allahabad', 'Bara Banki', 'Faizabad', 'Ambedkar Nagar', 'Sultanpur', 'Bahraich', 'Shrawasti', 'Balrampur', 'Gonda', 'Siddharthnagar', 'Basti', 'Sant Kabir Nagar', 'Mahrajganj', 'Gorakhpur', 'Kushinagar', 'Deoria', 'Azamgarh', 'Mau', 'Ballia', 'Jaunpur', 'Ghazipur', 'Chandauli', 'Varanasi', 'Sant Ravidas Nagar (Bhadohi)', 'Mirzapur', 'Sonbhadra', 'Etah', 'Kanshiram Nagar'],
        'BIHAR' => ['Pashchim Champaran', 'Purba Champaran', 'Sheohar', 'Sitamarhi', 'Madhubani', 'Supaul', 'Araria', 'Kishanganj', 'Purnia', 'Katihar', 'Madhepura', 'Saharsa', 'Darbhanga', 'Muzaffarpur', 'Gopalganj', 'Siwan', 'Saran', 'Vaishali', 'Samastipur', 'Begusarai', 'Khagaria', 'Bhagalpur', 'Banka', 'Munger', 'Lakhisarai', 'Sheikhpura', 'Nalanda', 'Patna', 'Bhojpur', 'Buxar', 'Kaimur (Bhabua)', 'Rohtas', 'Aurangabad', 'Gaya', 'Nawada', 'Jamui', 'Jehanabad', 'Arwal'],

        'SIKKIM' => ['North  District', 'West District', 'South District', 'East District'],
        'ARUNACHAL PRADESH' => ['Tawang', 'West Kameng', 'East Kameng', 'Papum Pare', 'Upper Subansiri', 'West Siang', 'East Siang', 'Changlang', 'Tirap', 'Lower Subansiri', 'Kurung Kumey', 'Lower Dibang Valley', 'Lohit', 'Anjaw'],
        'NAGALAND' => ['Mon', 'Mokokchung', 'Zunheboto', 'Wokha', 'Dimapur', 'Phek', 'Tuensang', 'Longleng', 'Kohima', 'Peren'],
        'MANIPUR' => ['Senapati', 'Tamenglong', 'Churachandpur', 'Bishnupur', 'Thoubal', 'Imphal West', 'Imphal East', 'Ukhrul', 'Chandel'],
        'MIZORAM' => ['Mamit', 'Aizawl', 'Champhai', 'Serchhip', 'Lunglei', 'Lawngtlai', 'Saiha'],
        'TRIPURA' => ['West Tripura', 'South Tripura', 'Dhalai', 'North Tripura'],
        'MEGHALAYA' => ['West Garo Hills', 'East Garo Hills', 'South Garo Hills', 'West Khasi Hills', 'Ribhoi', 'East Khasi Hills', 'Jaintia Hills'],
        'ASSAM' => ['Kokrajhar', 'Dhubri', 'Goalpara', 'Barpeta', 'Morigaon', 'Nagaon', 'Sonitpur', 'Lakhimpur', 'Dhemaji', 'Tinsukia', 'Dibrugarh', 'Sivasagar', 'Jorhat', 'Golaghat', 'Karbi Anglong', 'Dima Hasao', 'Cachar', 'Karimganj', 'Hailakandi', 'Bongaigaon', 'Chirang', 'Kamrup', 'Kamrup Metropolitan', 'Nalbari', 'Baksa', 'Darrang', 'Udalguri'],
        'WEST BENGAL' => ['Darjiling', 'Jalpaiguri', 'Koch Bihar', 'Uttar Dinajpur', 'Dakshin Dinajpur', 'Maldah', 'Murshidabad', 'Birbhum', 'Barddhaman', 'Nadia', 'North Twenty Four Parganas', 'Hugli', 'Bankura', 'Puruliya', 'Haora', 'Kolkata', 'South Twenty Four Parganas', 'Paschim Medinipur', 'Purba Medinipur'],
        'JHARKHAND' => ['Garhwa', 'Chatra', 'Kodarma', 'Giridih', 'Deoghar', 'Godda', 'Sahibganj', 'Pakur', 'Dhanbad', 'Bokaro', 'Lohardaga', 'Purbi Singhbhum', 'Palamu', 'Latehar', 'Hazaribagh', 'Ramgarh', 'Dumka', 'Jamtara', 'Ranchi', 'Khunti', 'Gumla', 'Simdega', 'Pashchimi Singhbhum', 'Saraikela-Kharsawan'],
        'ODISHA' => ['Bargarh', 'Jharsuguda', 'Sambalpur', 'Debagarh', 'Sundargarh', 'Kendujhar', 'Mayurbhanj', 'Baleshwar', 'Bhadrak', 'Kendrapara', 'Jagatsinghapur', 'Cuttack', 'Jajapur', 'Dhenkanal', 'Anugul', 'Nayagarh', 'Khordha', 'Puri', 'Ganjam', 'Gajapati', 'Kandhamal', 'Baudh', 'Subarnapur', 'Balangir', 'Nuapada', 'Kalahandi', 'Rayagada', 'Nabarangapur', 'Koraput', 'Malkangiri'],
        'CHHATTISGARH' => ['Koriya', 'Surguja', 'Jashpur', 'Raigarh', 'Korba', 'Janjgir - Champa', 'Bilaspur', 'Kabeerdham', 'Rajnandgaon', 'Durg', 'Raipur', 'Mahasamund', 'Dhamtari', 'Uttar Bastar Kanker', 'Bastar', 'Narayanpur', 'Dakshin Bastar Dantewada', 'Bijapur'],
        'MADHYA PRADESH' => ['Sheopur', 'Morena', 'Bhind', 'Gwalior', 'Datia', 'Shivpuri', 'Tikamgarh', 'Chhatarpur', 'Panna', 'Sagar', 'Damoh', 'Satna', 'Rewa', 'Umaria', 'Neemuch', 'Mandsaur', 'Ratlam', 'Ujjain', 'Shajapur', 'Dewas', 'Dhar', 'Indore', 'Khargone (West Nimar)', 'Barwani', 'Rajgarh', 'Vidisha', 'Bhopal', 'Sehore', 'Raisen', 'Betul', 'Harda', 'Hoshangabad', 'Katni', 'Jabalpur', 'Narsimhapur', 'Dindori', 'Mandla', 'Chhindwara', 'Seoni', 'Balaghat', 'Guna', 'Ashoknagar', 'Shahdol', 'Anuppur', 'Sidhi', 'Singrauli', 'Jhabua', 'Alirajpur', 'Khandwa (East Nimar)', 'Burhanpur'],
        'GUJARAT' => ['Kachchh', 'Banas Kantha', 'Patan', 'Mahesana', 'Sabar Kantha', 'Gandhinagar', 'Ahmadabad', 'Surendranagar', 'Rajkot', 'Jamnagar', 'Porbandar', 'Junagadh', 'Amreli', 'Bhavnagar', 'Anand', 'Kheda', 'Panch Mahals', 'Dohad', 'Vadodara', 'Narmada', 'Bharuch', 'The Dangs', 'Navsari', 'Valsad', 'Surat', 'Tapi'],
        'DAMAN & DIU' => ['Diu', 'Daman'],
        'DADRA & NAGAR HAVELI' => ['Dadra & Nagar Haveli'],
        'MAHARASHTRA' => ['Nandurbar', 'Dhule', 'Jalgaon', 'Buldana', 'Akola', 'Washim', 'Amravati', 'Wardha', 'Nagpur', 'Bhandara', 'Gondiya', 'Gadchiroli', 'Chandrapur', 'Yavatmal', 'Nanded', 'Hingoli', 'Parbhani', 'Jalna', 'Aurangabad', 'Nashik', 'Thane', 'Mumbai Suburban', 'Mumbai', 'Raigarh', 'Pune', 'Ahmadnagar', 'Bid', 'Latur', 'Osmanabad', 'Solapur', 'Satara', 'Ratnagiri', 'Sindhudurg', 'Kolhapur', 'Sangli'],
        'ANDHRA PRADESH' => ['Adilabad', 'Nizamabad', 'Karimnagar', 'Medak', 'Hyderabad', 'Rangareddy', 'Mahbubnagar', 'Nalgonda', 'Warangal', 'Khammam', 'Srikakulam', 'Vizianagaram', 'Visakhapatnam', 'East Godavari', 'West Godavari', 'Krishna', 'Guntur', 'Prakasam', 'Sri Potti Sriramulu Nellore', 'Y.S.R.', 'Kurnool', 'Anantapur', 'Chittoor'],
        'KARNATAKA' => ['Belgaum', 'Bagalkot', 'Bijapur', 'Bidar', 'Raichur', 'Koppal', 'Gadag', 'Dharwad', 'Uttara Kannada', 'Haveri', 'Bellary', 'Chitradurga', 'Davanagere', 'Shimoga', 'Udupi', 'Chikmagalur', 'Tumkur', 'Bangalore', 'Mandya', 'Hassan', 'Dakshina Kannada', 'Kodagu', 'Mysore', 'Chamarajanagar', 'Gulbarga', 'Yadgir', 'Kolar', 'Chikkaballapura', 'Bangalore Rural', 'Ramanagara'],
        'GOA' => ['North Goa', 'South Goa'],
        'KERALA' => ['Kasaragod', 'Kannur', 'Wayanad', 'Kozhikode', 'Malappuram', 'Palakkad', 'Thrissur', 'Ernakulam', 'Idukki', 'Kottayam', 'Alappuzha', 'Pathanamthitta', 'Kollam', 'Thiruvananthapuram'],
        'TAMIL NADU' => ['Thiruvallur', 'Chennai', 'Kancheepuram', 'Vellore', 'Tiruvannamalai', 'Viluppuram', 'Salem', 'Namakkal', 'Erode', 'The Nilgiris', 'Dindigul', 'Karur', 'Tiruchirappalli', 'Perambalur', 'Ariyalur', 'Cuddalore', 'Nagapattinam', 'Thiruvarur', 'Thanjavur', 'Pudukkottai', 'Sivaganga', 'Madurai', 'Theni', 'Virudhunagar', 'Ramanathapuram', 'Thoothukkudi', 'Tirunelveli', 'Kanniyakumari', 'Dharmapuri', 'Krishnagiri', 'Coimbatore', 'Tiruppur'],
        'PUDUCHERRY' => ['Yanam', 'Puducherry', 'Mahe', 'Karaikal'],
        'ANDAMAN & NICOBAR ISLANDS' => ['Nicobars', 'North  & Middle Andaman', 'South Andaman']
      },
      birthplace_cn: {
        '北京市' => ['北京市'],
        '天津市' => ['天津市'],
        '上海市' => ['上海市'],
        '重庆市' => ['重庆市'],
        '安徽省' => ['合肥', '宿州', '淮北', '阜阳', '蚌埠', '淮南', '滁州', '马鞍', '芜湖', '铜陵', '安庆', '黄山', '六安', '池州', '宣城', '亳州', '界首', '明光', '天长', '桐城', '宁国', '巢湖'],
        '福建省' => ['福州', '南平', '三明', '莆田', '泉州', '漳州', '龙岩', '宁德', '福清', '长乐', '邵武', '武夷山', '建瓯', '建阳', '永安', '石狮', '晋江', '南安', '龙海', '漳平', '福安', '福鼎'],
        '甘肃省' => ['兰州', '嘉峪关', '金昌', '白银', '天水', '酒泉', '张掖', '武威', '庆阳', '平凉', '定西', '陇南', '玉门', '敦煌', '临夏', '合作'],
        '广东省' => ['广州', '深圳', '清远', '韶关', '河源', '梅州', '潮州', '汕头', '揭阳', '汕尾', '惠州', '东莞', '珠海', '中山', '江门', '佛山', '肇庆', '云浮', '阳江', '茂名', '湛江', '英德', '连州', '乐昌', '南雄', '兴宁', '普宁', '陆丰', '恩平', '台山', '开平', '鹤山', '高要', '四会', '罗定', '阳春', '化州', '信宜', '高州', '吴川', '廉江', '雷州'],
        '贵州省' => ['贵阳', '六盘水', '遵义', '安顺', '毕节', '铜仁', '清镇', '赤水', '仁怀', '凯里', '都匀', '兴义', '福泉'],
        '河北省' => ['石家庄', '邯郸', '唐山', '保定', '秦皇岛', '邢台', '张家口', '承德', '沧州', '廊坊', '衡水', '辛集', '藁城', '晋州', '新乐', '鹿泉', '遵化', '迁安', '霸州', '三河', '定州', '涿州', '安国', '高碑店', '泊头', '任丘', '黄骅', '河间', '冀州', '深州', '南宫', '沙河', '武安'],
        '黑龙江省' => ['齐齐哈尔', '黑河', '大庆', '伊春', '鹤岗', '佳木斯', '双鸭山', '七台河', '鸡西', '牡丹江', '绥化', '双城', '尚志', '五常', '讷河', '北安', '五大连池', '铁力', '同江', '富锦', '虎林', '密山', '绥芬河', '海林', '宁安', '安达', '肇东', '海伦'],
        '河南省' => ['郑州', '开封', '洛阳', '平顶山', '安阳', '鹤壁', '新乡', '焦作', '濮阳', '许昌', '漯河', '三门峡', '南阳', '商丘', '周口', '驻马店', '信阳', '济源', '巩义', '邓州', '永城', '汝州', '荥阳', '新郑', '登封', '新密', '偃师', '孟州', '沁阳', '卫辉', '辉县', '林州', '禹州', '长葛', '舞钢', '义马', '灵宝', '项城'],
        '湖北省' => ['武汉', '十堰', '襄阳', '荆门', '孝感', '黄冈', '鄂州', '黄石', '咸宁', '荆州', '宜昌', '随州', '仙桃', '天门', '潜江', '丹江口', '老河口', '枣阳', '宜城', '钟祥', '汉川',' 应城', '安陆', '广水', '麻城', '武穴', '大冶', '赤壁', '石首', '洪湖', '松滋', '宜都', '枝江', '当阳', '恩施', '利川'],
        '湖南省' => ['长沙', '衡阳', '张家界', '常德', '益阳', '岳阳', '株洲', '湘潭', '郴州', '永州', '邵阳', '怀化', '娄底', '耒阳', '常宁', '浏阳', '津市', '沅江', '汨罗', '临湘', '醴陵',' 湘乡', '韶山', '资兴', '武冈', '洪江', '冷水江', '涟源', '吉首'],
        '吉林省' => ['长春', '吉林', '白城', '松原', '四平', '辽源', '通化', '白山', '德惠', '九台', '榆树', '磐石', '蛟河', '桦甸', '舒兰', '洮南', '大安', '双辽', '公主岭', '梅河口', '集安',' 临江', '延吉', '图们', '敦化', '珲春', '龙井', '和龙, 扶余'],
        '江西省' => ['南昌', '九江', '景德镇', '鹰潭', '新余', '萍乡', '赣州', '上饶', '抚州', '宜春', '吉安', '瑞昌', '乐平', '瑞金', '德兴', '丰城', '樟树', '高安', '井冈山', '贵溪'],
        '江苏省' => ['南京', '徐州', '连云港', '宿迁', '淮安', '盐城', '扬州', '泰州', '南通', '镇江', '常州', '无锡', '苏州', '江阴', '宜兴', '邳州', '新沂', '金坛', '溧阳', '常熟', '张家港',' 太仓', '昆山', '如皋', '海门', '启东', '大丰', '东台', '高邮', '仪征', '扬中', '句容', '丹阳', '兴化', '泰兴', '靖江'],
        '辽宁省' => ['沈阳', '大连', '朝阳', '阜新', '铁岭', '抚顺', '本溪', '辽阳', '鞍山', '丹东', '营口', '盘锦', '锦州', '葫芦岛', '新民', '瓦房店', '普兰店', '庄河', '北票', '凌源', '调兵山', '开原', '灯塔', '海城', '凤城', '东港', '大石桥', '盖州', '凌海', '北镇', '兴城'],
        '山东省' => ['济南', '青岛', '聊城', '德州', '东营', '淄博', '潍坊', '烟台', '威海', '日照', '临沂', '枣庄', '济宁', '泰安', '莱芜', '滨州', '菏泽', '章丘', '胶州', '即墨', '平度', '莱西', '临清', '乐陵', '禹城', '安丘', '昌邑', '高密', '青州', '诸城', '寿光', '栖霞', '海阳', '龙口', '莱阳', '莱州', '蓬莱', '招远', '荣成', '乳山', '滕州', '曲阜', '邹城', '新泰', '肥城'],
        '陕西省' => ['西安', '延安', '铜川', '渭南', '咸阳', '宝鸡', '汉中', '榆林', '商洛', '安康', '韩城', '华阴', '兴平'],
        '山西省' => ['太原', '大同', '朔州', '阳泉', '长治', '晋城', '忻州', '吕梁', '晋中', '临汾', '运城', '古交', '潞城', '高平', '原平', '孝义', '汾阳', '介休', '侯马', '霍州', '永济', '河津'],
        '四川省' => ['成都', '广元', '绵阳', '德阳', '南充', '广安', '遂宁', '内江', '乐山', '自贡', '泸州', '宜宾', '攀枝花', '巴中', '达州', '资阳', '眉山', '雅安', '崇州', '邛崃', '都江堰',' 彭州', '江油', '什邡', '广汉', '绵竹', '阆中', '华蓥', '峨眉山', '万源', '简阳', '西昌'],
        '云南省' => ['昆明', '曲靖', '玉溪', '丽江', '昭通', '普洱', '临沧', '保山', '安宁', '宣威', '芒市', '瑞丽', '大理', '楚雄', '个旧', '开远', '蒙自', '弥勒', '景洪'],
        '浙江省' => ['杭州', '宁波', '湖州', '嘉兴', '舟山', '绍兴', '衢州', '金华', '台州', '温州', '丽水', '临安', '富阳', '建德', '慈溪', '余姚', '奉化', '平湖', '海宁', '桐乡', '诸暨', '嵊州', '江山', '兰溪', '永康', '义乌', '东阳', '临海', '温岭', '瑞安', '乐清', '龙泉'],
        '青海省' => ['西宁', '海东', '格尔木', '德令哈'],
        '海南省' => ['海口', '三亚', '三沙', '文昌', '琼海', '万宁', '东方', '儋州', '五指山'],
        '广西' => ['南宁', '桂林', '柳州', '梧州', '贵港', '玉林', '钦州', '北海', '防城港', '崇左', '百色', '河池', '来宾', '贺州'],
        '内蒙古' => ['呼和浩特', '包头', '乌海', '赤峰', '呼伦贝尔', '通辽', '乌兰察布', '鄂尔多斯', '巴彦淖尔', '满洲里', '扎兰屯', '牙克石', '根河', '额尔古纳', '乌兰浩特', '阿尔山', '霍林郭勒','锡林浩特', '二连浩特', '丰镇'],
        '宁夏' => ['银川', '石嘴山', '吴忠', '中卫', '固原', '灵武', '青铜峡'],
        '西藏' => ['拉萨', '日喀则'],
        '新疆' => ['乌鲁木齐', '克拉玛依', '石河子', '阿拉尔', '图木舒克', '五家渠', '北屯', '铁门关', '喀什', '双河', '阿克苏', '和田', '吐鲁番', '哈密', '阿图什', '阿拉山口', '博乐', '昌吉','阜康', '库尔勒', '伊宁', '奎屯', '塔城', '乌苏', '阿勒泰'],
        '香港' => ['香港'],
        '澳门' => ['澳门'],
        '台湾' => ['台湾']
      }
    }

    def city_list_for(profile)
      if I18n.locale == :en
        OPTIONS[:birthplace][profile.region] || []
      elsif I18n.locale == :"zh-CN"
        OPTIONS[:birthplace_cn][profile.region] || []
      end
    end

    def connection_btn_text(social_type)
      case social_type
      when :facebook then current_user.linked_to_facebook? ? 'Connected' : 'Facebook'
      when :twitter then current_user.linked_to_twitter? ? 'Connected' : 'Twitter'
      when :weibo then current_user.linked_to_weibo? ? I18n.t('my_account.connected') : t('social_network.weibo')
      when :tqq then current_user.linked_to_tqq? ? I18n.t('my_account.connected') : t('social_network.tqq')
      end
    end
  end
end
