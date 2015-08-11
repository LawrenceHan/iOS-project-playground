module V1::Account
  describe Registration::API do
    before { APP_CONFIG[:sms][:test_mode] = false }
    after { APP_CONFIG[:sms][:test_mode] = true }

    describe 'POST /v1/account/register/sms_sending' do
      it 'sends sms message with verification code' do
        expect(User).to receive(:generate_sms_token).with(6).and_return 'abcdef'
        expect(User).to receive(:send_validation_sms).with('abcdef', '15800681905')
        post '/v1/account/register/sms_sending', phone: '15800681905'
        expect(response.status).to eq 201
      end

      it 'not to send sms message if phone already used' do
        create :user, phone: '15800681905'
        post '/v1/account/register/sms_sending', phone: '15800681905'
        expect(response.status).to eq 422
        expect(response.body).to eq JSON.generate(error: ['Phone number already used'])
      end

      it 'not to send sms message if last sms message was sent in 2 mins' do
        expect(User).to receive(:generate_sms_token).with(6).and_return 'abcdef'
        expect(User).to receive(:send_validation_sms).with('abcdef', '15800681905')
        Timecop.freeze 120.seconds.ago do
          post '/v1/account/register/sms_sending', phone: '15800681905'
        end
        expect(response.status).to eq 201

        Timecop.freeze 1.second.ago do
          post '/v1/account/register/sms_sending', phone: '15800681905'
        end
        expect(response.status).to eq 201
      end
    end

    describe 'POST /v1/account/register' do
      it 'creates a new user with session' do
        expect_any_instance_of(User).to receive(:sms_token_match_with).once.and_return(true)
        allow_any_instance_of(User).to receive(:username).and_return('care01')
        expect {
          post '/v1/account/register', user: {email: 'test@test.com', password: 'abcdef123456', phone: '15800681905', sms_token: '123456'}
        }.to change { User.count }.by(1)
        expect(response.status).to eq 201
        expect(response.body).to eq JSON.generate(phone: '15800681905', email: 'test@test.com', username: 'care01')
      end

      it 'creates a new user with redis' do
        $redis.set '15800681905', '123456'
        expect_any_instance_of(User).to receive(:sms_token_match_with).with('15800681905', '123456').once.and_return(true)
        allow_any_instance_of(User).to receive(:username).and_return('care01')
        expect {
          post '/v1/account/register', user: {email: 'test@test.com', password: 'abcdef123456', phone: '15800681905', sms_token: '123456'}
        }.to change { User.count }.by(1)
        expect(response.status).to eq 201
        expect(response.body).to eq JSON.generate(phone: '15800681905', email: 'test@test.com', username: 'care01')
      end

      it 'fails to create if sms token expired' do
        expect(User).to receive(:generate_sms_token).with(6).and_return 'abcdef'
        expect(User).to receive(:send_validation_sms).with('abcdef', '15800681905')
        Timecop.freeze 1.hour.ago do
          post '/v1/account/register/sms_sending', phone: '15800681905'
        end
        expect {
          post '/v1/account/register', user: {email: 'test@test.com', password: 'abcdef123456', phone: '15800681905', sms_token: '123456'}
        }.not_to change { User.count }
        expect(response.status).to eq 422
        expect(response.body).to eq JSON.generate(error: ["The token has expired as either you clicked the link twice or the link was sent more than an hour back. Please request a new token."])
      end

      it 'failed to create with invalid attrs' do
        expect_any_instance_of(User).to receive(:sms_token_match_with).once.and_return(true)
        expect {
          post '/v1/account/register', user: {email: 'test', password: 'abcdef123456', phone: '15800681905', sms_token: '123456'}
        }.not_to change { User.count }
        expect(response.status).to eq 422
        expect(response.body).to eq JSON.generate(error: ['Email is invalid'])
      end
    end
  end
end
