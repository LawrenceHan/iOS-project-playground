require 'rails_helper'

describe 'db:doctors:doc' do

  def setupPhysicians(vendor_ids)
    vendor_ids.each {
      |vendor_id|
      p = create :physician, name: 'Physician ' + vendor_id.to_s, vendor_id: vendor_id
      p.save
    }
  end

  def checkProperties(vendor_ids)
   required_properties = [
        'vendor_id', 'Name', 'Title', 'Department', 'Introduction', 'Description']
      vendor_ids.each { |vendor_id|
        doc = Physician.find_by(vendor_id: vendor_id).doc
        expect(doc).not_to be_nil, "expected doc for #{vendor_id}, was nil"
        # make sure we're getting the English
        expect(doc['Introduction']).to eq('暂无')
        required_properties.each { |property|
          expect(doc).to include(property), "property #{property} should exist"
          expect(doc[property]).to_not be(nil), "property #{property} should not be nil"
          expect(doc[property].length).to be > 0, "property #{property} should be non-zero"
        }
      }
  end

  # it "rake task db:doctors:doc can import sample data" do
  #   vendor_ids = [
  #     :M00007836,
  #     :M00013131,
  #     :M00013132,
  #     :M00013153,
  #     :M00015616,
  #     :M00016125,
  #     :M00016126,
  #     :M00089213,
  #     :M00139753,
  #     :M00142939,
  #     :M00142941,
  #     :M00431555,
  #     :M00468343
  #   ]
  #   setupPhysicians(vendor_ids)

  #   Carevoice::Application.load_tasks
  #   file_path = File.expand_path("H00001010.xlsx", File.dirname(__FILE__))
  #   puts file_path
  #   Rake.application.invoke_task("db:doctors:doc[#{file_path}]")

  #   expect(Physician.find_by(vendor_id: :M00007836).doc['Department']).to eq('骨科')
  #   # note: ! point in Chinese has extra spacing built-in...
  #   expect(Physician.find_by(vendor_id: :M00013153).doc['Introduction']).to eq('岂能尽如人意，但求无愧我心！')

  #   checkProperties(vendor_ids)
  # end

  # it "rake task db:doctors:doc can import sample data 2" do
  #   vendor_ids = [
  #     :M00426837,
  #     :M00806913,
  #     :M00806916,
  #     :M00806917,
  #     :M00806915,
  #     :M00806918,
  #     :M00426809,
  #     :M00809096
  #   ]
  #   setupPhysicians(vendor_ids)

  #   Carevoice::Application.load_tasks
  #   file_path = File.expand_path("H00128266.xlsx", File.dirname(__FILE__))
  #   Rake.application.invoke_task("db:doctors:doc[#{file_path}]")
  #   checkProperties(vendor_ids)
  # end


  it "rake task db:doctors:doc can import sample data 3" do
    vendor_ids = [
      'd6a2a861-10fc-4cee-857a-c150ac5e62e4',
      'b05d5267-8f33-47d7-ae25-17de9900bbaf',
      '73dd4246-0a51-4109-bdbf-60f1bec96a7a',
      '1826d895-41fa-4391-9a78-bdaf7067ec66',
      '3b4abd50-eece-42a0-ad09-27d7e3fc53a2',
      'ab019840-c09d-44fc-8c8a-4cb35a590e78',
      'eaed793b-e810-4f80-b815-2a3b2fb52fd2',
      '7efbbe76-4d47-4e15-accc-c29ad9206c54',
      '97b05e29-cff3-48db-8a7d-d9656422de5d',
      'c79db051-d16b-446f-81f0-17b45036bbff',
      'daba2204-d05f-44b5-9408-3d1955c0b59b',
      '590cce4d-847d-483b-af66-525b4e185c52',
      'be045547-a0b3-40db-9caf-c82c61b2988b',
      'd8387002-1fe7-4d84-a23b-edd62e92d47f',
      'b4444428-fa96-4c19-bd6d-8b3d18230d4a',
      '0aaa2f3c-8951-49ee-8d63-1fa246a713c6',
      'adb44ddf-690c-4ef9-8595-4d1779ac600f',
      '417ddfd9-625b-4df5-b2d9-149f4e7b9861',
      '50d2cf8a-acd7-4c36-9321-6dd738eaa207'
    ]
    setupPhysicians(vendor_ids)

    Carevoice::Application.load_tasks
    file_path = File.expand_path("H00125536.xlsx", File.dirname(__FILE__))
    Rake.application.invoke_task("db:doctors:doc[#{file_path}]")
    checkProperties(vendor_ids)
  end
end
