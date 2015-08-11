require 'rails_helper'

RSpec.describe Physician do
  describe '#doc_with_hospital_name' do
    let(:hospital) { create :hospital, name: 'Hospital' }
    let(:physician) { create :physician, hospital: hospital, doc: {hospital_name: 'hopital', description: 'yeah'} }

    it 'merges hospital name' do
      expect(physician.doc_with_hospital_name).to eq({'hospital_name' => 'Hospital', 'description' => 'yeah'})
    end

    it 'default physician has gender unknown' do
      expect(physician.gender).to eq('unknown')
    end
  end

  describe '#translate_to_pinyin' do
    let(:physician) { switch_locale('zh-CN') { create :physician, name: '张三丰' } }

    it 'translate to pinyin' do
      translation = physician.translations.find_by(locale: 'zh-CN')
      expect(translation.name).to eq '张三丰'
      translation = physician.translations.find_by(locale: 'en')
      expect(translation.name).to eq 'Zhang San Feng'
    end
  end

  describe 'physician creation with gender' do
    let(:hospital) { create :hospital, name: 'Hospital' }
    let(:physician) { create :physician, gender: 'male', hospital: hospital, doc: {hospital_name: 'hopital', description: 'yeah'} }

    it 'correct gender returned' do
      expect(physician.gender).to eq('male')
    end

    it 'female gender works' do
      physician.gender = 'female'
      expect(physician.valid?).to eq(true)
      physician.save!
      physician.reload
      expect(physician.gender).to eq('female')
    end

    it 'unknown gender works' do
      physician.gender = 'unknown'
      expect(physician.valid?).to eq(true)
      physician.save!
      physician.reload
      expect(physician.gender).to eq('unknown')
    end

    it 'nil gender is rejected' do
      physician.gender = nil
      expect(physician.valid?).to eq(false)
      expect { physician.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'invalid gender is rejected' do
      physician.gender = 'unspecified'
      expect(physician.valid?).to eq(false)
      expect { physician.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'empty string gender is rejected' do
      physician.gender = ''
      expect(physician.valid?).to eq(false)
      expect { physician.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
