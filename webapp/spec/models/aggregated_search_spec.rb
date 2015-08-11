require 'rails_helper'

# ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe AggregatedSearch do

  describe 'search on strings, restricted by entity type' do
    let!(:hospital) { create :hospital, name: '上海市公共卫生临床中心社区分部' }
    let!(:department) { create :department, name: '骨科' }
    let!(:physician) { create :physician, name: '云米格', department: department, hospital: hospital }
    let!(:speciality) { create :speciality }

    before do
      create :physicians_speciality, physician: physician, speciality: speciality
      #@t1 = create :translation,
        #entity_id: @hospital.id,
        #entity_type: 'Hospital',
        #content: 'St-Yun'
      #@t2 = create :translation,
        #entity_id: @physician.id,
        #entity_type: 'Physician',
        #content: 'Michael Yun'
    end

    it 'original search' do
      results = AggregatedSearch.search(query: { text: '云米格' }).pluck(:searchable_id)
      expect(results).to contain_exactly(physician.id)
    end

    #it 'universal search' do
      #results = AggregatedSearch.search(query: { text: 'Yun' }).pluck(:searchable_id)
      #expect(results).to contain_exactly(@hospital.id, @physician.id)
    #end

    #it 'type specific search' do
      #results = AggregatedSearch.search(query: { text: 'Michael', type: 'Physician' }).pluck(:searchable_id)
      #expect(results).to contain_exactly(@physician.id)
    #end

    #it 'types specific search' do
      #results = AggregatedSearch
        #.search(query: { text: 'Yun', type: 'Hospital, Physician' }).pluck(:searchable_id)
      #expect(results).to contain_exactly(@hospital.id, @physician.id)
    #end

    #it 'case-insensitive (uppercase)' do
      #results = AggregatedSearch.search(query: { text: 'MICHAEL', type: 'Physician' }).pluck(:searchable_id)
      #expect(results).to contain_exactly(@physician.id)
    #end

    #it 'case-insensitive (lowercase)' do
      #results = AggregatedSearch.search(query: { text: 'michael', type: 'Physician' }).pluck(:searchable_id)
      #expect(results).to contain_exactly(@physician.id)
    #end

    #it 'partial matches (start string)' do
      #results = AggregatedSearch.search(query: { text: 'MIC', type: 'Physician' }).pluck(:searchable_id)
      #expect(results).to contain_exactly(@physician.id)
    #end

    #it 'partial matches (end string)' do
      #results = AggregatedSearch.search(query: { text: 'ael', type: 'Physician' }).pluck(:searchable_id)
      #expect(results).to contain_exactly(@physician.id)
    #end

    #it 'polymorphic results' do
      #results = AggregatedSearch.search(query: { text: 'Yun', type: 'Hospital,Physician' })
      #expect(results.map(&:searchable_entity)).to contain_exactly(@physician, @hospital)
    #end
  end

  describe 'attributes specific searches' do
    let(:hospital) { create :hospital }
    let(:department) { create :department }
    let(:speciality) { create :speciality }

    before do
      doctors = [
        { name: '佟大年', name_en: 'Mike Manson' },
        { name: '佟幕新', name_en: 'Bob Black' },
        { name: '佟曼玉', name_en: 'Aaron Affleck' }
      ]

      @doctor_name_to_id = {}

      doctors.each { |doctor|
        physician = create :physician, name: doctor[:name], department: department, hospital: hospital
        create :physicians_speciality, physician: physician, speciality: speciality

        @doctor_name_to_id[doctor[:name]] = physician.id

        #create :translation,
          #entity_id: physician.id,
          #entity_type: 'Physician',
          #content: doctor[:name_en]
      }
    end

    #it 'search by name, English' do
      #results = AggregatedSearch.search(query: { text: 'Mike', type: 'Physician' }).pluck(:searchable_id)
      #expect(results).to contain_exactly(@doctor_name_to_id['佟大年'])
    #end

    it 'search by name, Chinese' do
      results = AggregatedSearch.search(query: { text: '佟曼玉', type: 'Physician' }).pluck(:searchable_id)
      expect(results).to contain_exactly(@doctor_name_to_id['佟曼玉'])
    end
  end

end
