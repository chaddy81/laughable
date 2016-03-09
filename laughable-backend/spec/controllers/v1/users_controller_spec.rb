require 'rails_helper'
require 'database_cleaner'

RSpec.describe V1::UsersController, :type => :controller do
  render_views

  describe 'POST #login ' do
    it 'should fail because the user id and password are not specified' do
      post :login, format: :json, user_id: nil, password: nil
      result = JSON.parse(response.body)
      expect(response.status).to eq 400
      expect(result['success']).to eq false
      expect(result['errors']['password']).to eq 'cannot be empty'
      expect(result['errors']['user_id']).to eq 'cannot be empty'
    end

    it 'should fail because the user id does not exist' do
      post :login, format: :json, user_id: 0, password: 'password'
      result = JSON.parse(response.body)
      expect(response.status).to eq 400
      expect(result['success']).to eq false
      expect(result['errors']['user_id']).to eq 'is invalid'
    end
    it 'should fail because the password is invalid' do
      user = User.create(password: 'password')
      post :login, format: :json, user_id: user.id, password: 'invalid'
      result = JSON.parse(response.body)
      expect(response.status).to eq 400
      expect(result['success']).to eq false
      expect(result['errors']['password']).to eq 'is invalid'
    end
    it 'should succeed because the password is correct' do
      user = User.create(password: 'password')
      post :login, format: :json, user_id: user.id, password: 'password'
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['errors']).to be nil
      expect(result['access_token']).to eq user.access_token
    end
  end

  describe 'POST #create' do
    it 'should create a user' do
      old_user_count = User.count
      old_api_count = ApiKey.count

      user =
        {
          username: 'username',
          first_name: 'first_name',
          middle_name: 'middle_name',
          last_name: 'last_name',
          email: 'email@email.email',
          password: 'test_password',
          admin: false,
          fake_user: true,
          phone_number: '18000000000'
        }

      post :create, format: :json, user: user

      expect(User.count).to eq (old_user_count + 1)
      expect(ApiKey.count).to eq (old_api_count + 1)
      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      api_key = ApiKey.find_by(user_id: result['user']['id'])
      expect(api_key.access_token).to_not be nil

      expect(result['success']).to eq true
      expect(result['user']['username']).to eq user[:username]
      expect(result['user']['first_name']).to eq user[:first_name]
      expect(result['user']['middle_name']).to eq user[:middle_name]
      expect(result['user']['last_name']).to eq user[:last_name]
      expect(result['user']['email']).to eq user[:email]

    end

    describe 'it should not create a user' do
      it 'because there is no user data passed' do
        post :create, format: :json

        expect(response.status).to eq 400
        result = JSON.parse(response.body)
        expect(result['success']).to eq false
        expect(result['errors']).to_not be nil
        expect(result['errors']['error']).to eq 'user hash cannot be empty'
      end

      #it 'because no username is passed' do
      #  user =
      #    {
      #      first_name: 'first_name',
      #      middle_name: 'middle_name',
      #      last_name: 'last_name',
      #      email: 'email@email.email',
      #      password: 'test_password',
      #      admin: false,
      #      fake_user: true,
      #      phone_number: '18000000000'
      #    }
      #
      #  post :create, format: :json, user: user
      #
      #  expect(response.status).to eq 400
      #  result = JSON.parse(response.body)
      #  expect(result['success']).to eq false
      #  expect(result['errors']).to_not be nil
      #  expect(result['errors'].first['username']).to eq 'is missing'
      #
      #end

      #it 'because no password is passed' do
#
      #  user =
      #    {
      #      username: 'username',
      #      first_name: 'first_name',
      #      middle_name: 'middle_name',
      #      last_name: 'last_name',
      #      email: 'email@email.email',
      #      admin: false,
      #      fake_user: true,
      #      phone_number: '18000000000'
      #    }
#
      #  post :create, format: :json, user: user
#
      #  expect(response.status).to eq 400
      #  result = JSON.parse(response.body)
      #  expect(result['success']).to eq false
      #  expect(result['errors']).to_not be nil
      #  expect(result['errors'].first['password']).to eq 'is missing'
#
      #end
#
      #it 'because no email is passed' do
#
      #  user =
      #    {
      #      username: 'username',
      #      first_name: 'first_name',
      #      middle_name: 'middle_name',
      #      last_name: 'last_name',
      #      password: 'test_password',
      #      admin: false,
      #      fake_user: true,
      #      phone_number: '18000000000'
      #    }
#
      #  post :create, format: :json, user: user
#
      #  expect(response.status).to eq 400
      #  result = JSON.parse(response.body)
      #  expect(result['success']).to eq false
      #  expect(result['errors']).to_not be nil
      #  expect(result['errors'].first['email']).to eq 'is missing'
      #end

      #it 'because username, email, and password are missing' do
      #  user =
      #    {
      #      first_name: 'first_name',
      #      middle_name: 'middle_name',
      #      last_name: 'last_name',
      #      admin: false,
      #      fake_user: true,
      #      phone_number: '18000000000'
      #    }
#
      #  post :create, format: :json, user: user
#
      #  expect(response.status).to eq 400
      #  result = JSON.parse(response.body)
      #  expect(result['success']).to eq false
      #  expect(result['errors']).to_not be nil
      #  expect(result['errors'].include? ({ username: 'is missing' }))
      #  expect(result['errors'].include? ({ email: 'is missing' }))
      #  expect(result['errors'].include? ({ password: 'is missing' }))
      #end
    end
  end

  describe 'GET #show' do
    it 'should return status code 400 and success false' do
      get :show, id: 999999999, access_token: User.create.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 400

      expect(result['success']).to eq false
      expect(result['errors']['999999999']).to eq 'user with id 999999999 does not exist'
    end

    it 'should return status code 200, success true, and a comedian information' do
      values =
        {
          username: 'username', first_name: 'first_name', middle_name: 'middle_name',
          last_name: 'last_name', email: 'email@email.email', phone_number: '18000000000',
          password: 'test_password'
        }

      user = User.new(values)
      user.save!

      get :show, id: user.id, access_token: user.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 200

      expect(result['success']).to eq true

      res = result['user']

      expect(res['id']).to eq user.id
      expect(res['username']).to eq values[:username]
      expect(res['first_name']).to eq values[:first_name]
      expect(res['middle_name']).to eq values[:middle_name]
      expect(res['last_name']).to eq values[:last_name]
      expect(res['email']).to eq values[:email]
      expect(res['phone_number']).to eq values[:phone_number]
    end
  end

  describe 'PATCH #update' do
    it 'should return status code 200 and success true' do
      values =
        {
          username: 'username1', first_name: 'first_name1', middle_name: 'middle_name1',
          last_name: 'last_name1', email: 'email1@email.email', phone_number: '18000000001',
          password: 'test_password1', admin: true
        }

      user = User.new(values)
      user.save!

      new_values =
        {
          username: 'username123', first_name: 'first_name123', middle_name: 'middle_name123'
        }

      patch :update, id: user.id, user: new_values, access_token: user.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 200

      res = result['user']
      expect(res['username']).to eq new_values[:username]
      expect(res['first_name']).to eq new_values[:first_name]
      expect(res['middle_name']).to eq new_values[:middle_name]
      expect(res['last_name']).to eq values[:last_name]
      expect(res['email']).to eq values[:email]
      expect(res['phone_number']).to eq values[:phone_number]
    end
  end

  describe 'PUT #update' do
    it 'should return status code 200 and success true' do
      values =
        {
          username: 'username1', first_name: 'first_name1', middle_name: 'middle_name1',
          last_name: 'last_name1', email: 'email1@email.email', phone_number: '18000000001',
          password: 'test_password1', admin: true
        }

      user = User.new(values)
      user.save!

      new_values =
        {
          username: 'username123', first_name: 'first_name123', middle_name: 'middle_name123', admin: true
        }

      put :update, id: user.id, user: new_values, access_token: user.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 200

      res = result['user']
      expect(res['username']).to eq new_values[:username]
      expect(res['first_name']).to eq new_values[:first_name]
      expect(res['middle_name']).to eq new_values[:middle_name]
      expect(res['last_name']).to eq nil
      expect(res['email']).to eq nil
      expect(res['phone_number']).to eq nil
    end
  end

  #describe 'DELETE #destroy' do
#
  #  it 'should return status code 400 and success false' do
  #    delete :destroy, id: 9999999999
#
  #    result = JSON.parse(response.body)
  #    expect(response.status).to eq 400
  #    expect(result['success']).to eq false
  #    expect(result['errors'].first['error']).to eq 'user with id 9999999999 does not exist'
  #  end
  #  it 'should return status code 200 and success true' do
  #    values =
  #      {
  #        username: 'username1', first_name: 'first_name1', middle_name: 'middle_name1',
  #        last_name: 'last_name1', email: 'email1@email.email', phone_number: '18000000001',
  #        password: 'test_password1'
  #      }
#
  #    user = User.new(values)
  #    user.save!
#
  #    delete :destroy, id: user.id
#
  #    expect(response.status).to eq 200
  #    result = JSON.parse(response.body)
  #    expect(result['success']).to eq true
#
  #    expect(User.find_by(id: user.id)).to eq nil
#
  #  end
  #end

  describe 'GET #info' do
    it 'should return success true' do
      get :info, format: :json, access_token: User.create.access_token

      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
    end
  end
end
