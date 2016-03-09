require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'display helper' do
    it 'returns a hash of attributes' do
      user = User.new
      user.save!
      result = user.display_helper
      expect(result[:id]).to eq user.id
      expect(result[:username]).to eq user.username
      expect(result[:first_name]).to eq user.first_name
      expect(result[:middle_name]).to eq user.middle_name
      expect(result[:last_name]).to eq user.last_name
      expect(result[:email]).to eq user.email
      expect(result[:phone_number]).to eq user.phone_number
    end
  end

  describe 'access token' do
    it 'the access token is created successfully' do
      old_api_key_count = ApiKey.count
      user = User.new
      user.save!
      expect(ApiKey.count).to eq (old_api_key_count + 1)
    end

    it 'for a user is found' do
      user = User.new
      user.save!
      expect(user.access_token).to eq ApiKey.find_by(user_id: user.id).access_token
    end
  end
end
