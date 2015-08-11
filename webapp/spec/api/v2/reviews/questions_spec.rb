module V2::Reviews
  describe Questions::API do
    describe 'GET /v2/reviews/questions' do
      it 'gets questions by category' do
        questions = create_list :question, 2, category: 'hospital'
        get '/v2/reviews/questions', category: 'hospital'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.map { |q| q['id'] }).to match_array questions.map(&:id)
      end
    end

    describe 'GET /v2/reviews/questions (Chinese seed data in English)' do
      it 'gets questions by hospital' do
        question1 = create :question, category: 'hospital', content: 'Cleanliness'
        question2 = create :question, category: 'hospital', content: 'Waiting time', options: [["No waiting", 0], ["30 minutes", 30], ["2 hours", 120]]
        switch_locale 'zh-CN' do
          question1.content = '卫生情况'
          question1.save
          question2.content = '等待时间'
          question2.save
        end
        %w(en-US en_US en).each { |locale|
          get '/v2/reviews/questions', locale: locale, category: 'hospital'
          expect(response.status).to eq 200
          expect(response.body).not_to match(/translation missing/)
          expect(response.body).not_to match(/minute/), 'should consistently use symbol min for unit minutes'
          expect(response.body).not_to match(/hour/), 'should consistently use symbol hr for hours'
          expect(response.body).not_to match(/\p{Han}+/u)
          expect(response.body).to match(/Cleanliness/)
          expect(response.body).to match(/Waiting time/)
          expect(response.body).to match(/No waiting/)
          expect(response.body).to match(/30min/)
          expect(response.body).to match(/2hr/)
        }
      end

      it 'gets questions by physician' do
        question1 = create :question, category: 'physician', content: 'Friendly nature'
        question2 = create :question, category: 'physician', content: 'Consultation duration', options: [["无需等待", 0], ["30分钟", 30], ["2小时", 120]]
        switch_locale 'zh-CN' do
          question1.content = '态度友好'
          question1.save
          question2.content = '问诊效率'
          question2.save
        end
        %w(en-US en_US en).each { |locale|
          get '/v2/reviews/questions', locale: locale, category: 'physician'
          expect(response.status).to eq 200
          expect(response.body).not_to match(/translation missing/)
          expect(response.body).not_to match(/minute/), 'should consistently use symbol min for unit minutes'
          expect(response.body).not_to match(/hour/), 'should consistently use symbol hr for hours'
          expect(response.body).not_to match(/\p{Han}+/u)
          expect(response.body).to match(/Friendly nature/)
          expect(response.body).to match(/Consultation duration/)
          expect(response.body).to match(/No waiting/)
          expect(response.body).to match(/30min/)
          expect(response.body).to match(/2hr/)
        }
      end

      it 'gets questions by medication' do
        question = create :question, category: 'medication', content: 'Effectiveness'
        switch_locale 'zh-CN' do
          question.content = '药效明显'
          question.save
        end
        %w(en-US en_US en).each { |locale|
          get '/v2/reviews/questions', locale: locale, category: 'medication'
          expect(response.status).to eq 200
          expect(response.body).not_to match(/translation missing/)
          expect(response.body).not_to match(/minute/), 'should consistently use symbol min for unit minutes'
          expect(response.body).not_to match(/hour/), 'should consistently use symbol hr for hours'
          expect(response.body).not_to match(/\p{Han}+/u)
          expect(response.body).to match(/Effectiveness/)
        }
      end
    end

    describe 'GET /v2/reviews/questions (Indian seed data in Chinese)' do
      it 'gets questions by hospital' do
        question1 = create :question, category: 'hospital', content: 'Convenient location'
        question2 = create :question, category: 'hospital', content: 'Waiting time', options: [["No waiting", 0], ["30 minutes", 30], ["2 hours", 120]]
        switch_locale 'zh-CN' do
          question1.content = '优越的地理位置'
          question1.save
          question2.content = '等待时间'
          question2.save
        end
        %w(zh-CN).each { |locale|
          get '/v2/reviews/questions', locale: locale, category: 'hospital'
          expect(response.status).to eq 200
          expect(response.body).not_to match(/translation missing/), 'should have no translation missing for locale: ' + locale
          expect(response.body).not_to match(/\"content\":\"[^\p{Han}]+\"/u), 'should not have non-Chinese content for locale: ' + locale
          expect(response.body).to match(/优越的地理位置/u)
          expect(response.body).to match(/等待时间/u)
          expect(response.body).to match(/无需等待/u)
          expect(response.body).to match(/30分钟/u)
          expect(response.body).to match(/2小时/u)
        }
      end

      it 'gets questions by physician' do
        question1 = create :question, category: 'physician', content: 'Explains clearly'
        question2 = create :question, category: 'physician', content: 'Consultation duration', options: [["No waiting", 0], ["30 minutes", 30], ["2 hours", 120]]
        switch_locale 'zh-CN' do
          question1.content = '解释清楚准确'
          question1.save
          question2.content = '问诊效率'
          question2.save
        end
        %w(zh-CN).each { |locale|
          get '/v2/reviews/questions', locale: locale, category: 'physician'
          expect(response.status).to eq 200
          expect(response.body).not_to match(/translation missing/), 'should have no translation missing for locale: ' + locale
          expect(response.body).not_to match(/\"content\":\"[^\p{Han}]+\"/u), 'should not have non-Chinese content for locale: ' + locale
          expect(response.body).to match(/解释清楚准确/u)
          expect(response.body).to match(/问诊效率/u)
          expect(response.body).to match(/无需等待/u)
          expect(response.body).to match(/30分钟/u)
          expect(response.body).to match(/2小时/u)
        }
      end

      it 'gets questions by medication' do
        question = create :question, category: 'medication', content: 'Effectiveness'
        switch_locale 'zh-CN' do
          question.content = '药效明显'
          question.save
        end
        %w(zh-CN).each { |locale|
          get '/v2/reviews/questions', locale: locale, category: 'medication'
          expect(response.status).to eq 200
          expect(response.body).not_to match(/translation missing/), 'should have no translation missing for locale: ' + locale
          expect(response.body).not_to match(/\"content\":\"[^\p{Han}]+\"/u), 'should not have non-Chinese content for locale: ' + locale
          expect(response.body).to match(/药效明显/u)
        }
      end
    end
  end
end
