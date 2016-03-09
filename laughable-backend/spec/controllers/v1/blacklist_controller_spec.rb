require 'rails_helper'
require 'database_cleaner'

RSpec.describe V1::BlacklistController, type: :controller do
  render_views

  describe 'GET #info' do
    it 'should return success false and permission denied' do
      user = User.create
      get :info, format: :json, access_token: user.access_token
      expect(response.status).to eq 403
      result = JSON.parse(response.body)
      expect(result['success']).to eq false
      expect(result['errors']['user']).to eq 'does not have permission to do this'
    end

    it 'should return success false because the access token is missing' do
      get :info, format: :json
      expect(response.status).to eq 403
      result = JSON.parse(response.body)
      expect(result['success']).to eq false
      expect(result['errors']['access_token']).to eq 'is missing'
    end

    it 'should return success true and status 200' do
      user = User.create(admin: true)
      get :info, format: :json, access_token: user.access_token
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['success']).to eq true
    end
  end

  describe 'GET #list_all' do
    it 'fails because there are no blacklisted tracks' do
      user = User.create(admin: true)
      $redis.with { |conn| conn.del('blacklisted-tracks-ids') }

      get :list_all, format: :json, access_token: user.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 400
      expect(result['success']).to eq false
      expect(result['errors']['tracks']).to eq 'no blacklisted tracks'
    end

    it 'succeeds and lists all tracks correctly' do
      user = User.create(admin: true)
      track1 = Track.create
      track2 = Track.create

      $redis.with do |conn|
        conn.del('blacklisted-tracks-ids')
        entry = "#{track1.id}, #{track2.id}"
        conn.set('blacklisted-tracks-ids', entry)
      end

      get :list_all, format: :json, access_token: user.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['tracks']).not_to be nil
      expect(result['tracks'].first['id']).to eq track1.id
      expect(result['tracks'].second['id']).to eq track2.id
    end
  end

  describe 'GET #unblacklist' do
    describe 'should fail' do
      it 'because the track does not exist' do
        user = User.create(admin: true)
        get :unblacklist, format: :json, id: 0, access_token: user.access_token
        expect(response.status).to eq 400
        result = JSON.parse(response.body)
        expect(result['success']).to eq false
        expect(result['errors']['id']).to eq 'is invalid'
      end
    end

    it 'should succeed when there are multiple entries in a blacklist' do
      user = User.create(admin: true)
      $redis.with { |conn| conn.del('blacklisted-tracks-ids') }
      track1 = Track.create
      track2 = Track.create
      track3 = Track.create
      $redis.with do |conn|
        conn.set('blacklisted-tracks-ids', "#{track2.id}, #{track3.id}")
        conn.set('next_playlist_global', track1.id)
        conn.set("next_playlist_for_user-#{user.id}", track1.id)
      end

      get :unblacklist, format: :json, id: track2.id, access_token: user.access_token

      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      results_global = []
      results_user = []
      blacklisted_tracks = []
      $redis.with do |conn|
        results_global = conn.get('next_playlist_global').split(',').map(&:to_i)
        results_user = conn.get("next_playlist_for_user-#{user.id}").split(',').map(&:to_i)
        blacklisted_tracks = conn.get('blacklisted-tracks-ids').split(',').map(&:to_i)
      end
      expect(results_global[0]).to eq track1.id
      expect(results_global[1]).to eq track2.id
      expect(results_user[0]).to eq track1.id
      expect(results_user[1]).to eq track2.id
      expect(blacklisted_tracks[0]).to eq track3.id
    end

    it 'should succeed when there is an empty blacklist' do
      user = User.create(admin: true)
      $redis.with { |conn| conn.del('blacklisted-tracks-ids') }
      track1 = Track.create
      track2 = Track.create
      $redis.with do |conn|
        entry = { track1.id => 0 }
        conn.set('next_playlist_global', "#{track1.id}, #{track2.id}")
        conn.set("next_playlist_for_user-#{user.id}", "#{track1.id}, #{track2.id}")
      end

      get :unblacklist, format: :json, id: track2.id, access_token: user.access_token

      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      results_global = []
      results_user = []
      blacklisted_tracks = []
      $redis.with do |conn|
        results_global = conn.get('next_playlist_global').split(',').map(&:to_i)
        results_user = conn.get("next_playlist_for_user-#{user.id}").split(',').map(&:to_i)
        blacklisted_tracks = conn.get('blacklisted-tracks-ids').split(',').map(&:to_i)
      end
      expect(results_global[0]).to eq track1.id
      expect(results_global[1]).to eq track2.id
      expect(results_user[0]).to eq track1.id
      expect(results_user[1]).to eq track2.id
      expect(blacklisted_tracks).to eq []
    end
  end

  describe 'GET #blacklist' do
    describe 'it should fail' do
      it 'because the track does not exist' do
        user = User.create(admin: true)
        get :blacklist, format: :json, id: 0, access_token: user.access_token

        expect(response.status).to eq 400
        result = JSON.parse(response.body)
        expect(result['success']).to eq false
        expect(result['errors']['id']).to eq 'is invalid'
      end
    end

    it 'should succeed' do
      user = User.create(admin: true)
      # Set the blacklist first
      track1 = Track.create
      track2 = Track.create
      $redis.with do |conn|
        conn.set('next_playlist_global', "#{track1.id}, #{track2.id}")
        conn.set("next_playlist_for_user-#{user.id}", "#{track1.id}, #{track2.id}")
        conn.del('blacklisted-tracks-ids')
        conn.set('blacklisted-tracks-ids', "")
      end

      get :blacklist, format: :json, id: track1.id, access_token: user.access_token

      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      results_global = []
      results_user = []
      blacklisted_tracks = []
      $redis.with do |conn|
        results_global = conn.get('next_playlist_global').split(',').map(&:to_i)
        results_user = conn.get("next_playlist_for_user-#{user.id}").split(',').map(&:to_i)
        blacklisted_tracks = conn.get('blacklisted-tracks-ids').split(',').map(&:to_i)
      end
      expect(results_global[0]).to eq track2.id
      expect(results_user[0]).to eq track2.id
      expect(results_global.count).to eq 1
      expect(results_user.count).to eq 1
      expect(blacklisted_tracks.count).to eq 1
      expect(blacklisted_tracks[0]).to eq track1.id
    end
  end
end
