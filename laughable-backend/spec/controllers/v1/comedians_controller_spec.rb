require 'rails_helper'
require 'database_cleaner'

RSpec.describe V1::ComediansController, type: :controller do
  render_views

  def clear_redis(key)
    $redis.with { |c| c.del(key) }
  end

  def set_redis(key, value)
    $redis.with { |c| c.set(key, value) }
  end

  def get_redis(key)
    result = nil
    $redis.with do |c|
      result = c.get(key)
    end
    result
  end

  def clear_multiple_keys(key)
    $redis.with do |c|
      keys = c.keys("*#{key}*")
      keys.each { |k| c.del(k) }
    end
  end

  describe 'invisible comedians' do
    it 'should show 1 comedian' do
      Comedian.create(active: false)
      comedian2 = Comedian.create(active: true, staging_only: true)
      Track.create(comedian_id: comedian2.id)

      get :all, format: :json, access_token: User.create.access_token

      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['comedians'].count).to eq 1
      expect(result['comedians'][0]['id']).to eq comedian2.id
      expect(result['comedians'][0]['has_standup']).to eq true
      expect(result['comedians'][0]['is_guest']).to eq false
      expect(result['comedians'][0]['is_host']).to eq false
    end
  end

  describe 'GET #guestpodcastepisodes' do
    describe 'it should fail' do
      it 'because the comedian is not a guest' do
        user = User.create
        comedian = Comedian.create

        get :guestpodcastepisodes, id: comedian.id, access_token: user.access_token

        expect(response.status).to eq 400
        result = JSON.parse(response.body)
        expect(result['success']).to eq false
        expect(result['errors']['comedian']).to eq 'is not a guest in any podcast episodes'
      end
      it 'because the comedian does not exist' do
        user = User.create

        get :guestpodcastepisodes, id: 0, access_token: user.access_token

        expect(response.status).to eq 400
        result = JSON.parse(response.body)
        expect(result['success']).to eq false
        expect(result['errors']['comedian']).to eq 'does not exist'
      end
    end
    describe 'it should succeed' do
      it 'and it should return 2 episodes' do
        user = User.create
        comedian = Comedian.create
        podcast = Podcast.create
        Podcastepisode.create(podcast_id: podcast.id)
        episode1 = Podcastepisode.create(comedian_ids: [comedian.id], podcast_id: podcast.id)
        episode2 = Podcastepisode.create(comedian_ids: [comedian.id], podcast_id: podcast.id)

        get :guestpodcastepisodes, id: comedian.id, access_token: user.access_token
        expect(response.status).to eq 200
        result = JSON.parse(response.body)
        expect(result['success']).to eq true
        expect(result['comedian']['is_guest']).to eq true
        expect(result['comedian']['is_host']).to eq false
        expect(result['comedian']['has_standup']).to eq false
        expect(result['episodes'].count).to eq 2
        expect(result['episodes'][0]['id']).to eq episode1.id
        expect(result['episodes'][1]['id']).to eq episode2.id
      end
    end
  end

  describe 'GET #hostedpodcasts' do
    describe 'it should fail ' do
      it 'because the comedian is not hosting any podcasts' do
        user = User.create
        comedian = Comedian.create

        get :hostedpodcasts, id: comedian.id, access_token: user.access_token

        expect(response.status).to eq 400
        result = JSON.parse(response.body)
        expect(result['success']).to eq false
        expect(result['errors']['comedian']).to eq 'is not hosting any podcasts'
      end
      it 'because the comedian does not exist' do
        user = User.create

        get :hostedpodcasts, id: 0, access_token: user.access_token

        expect(response.status).to eq 400
        result = JSON.parse(response.body)
        expect(result['success']).to eq false
        expect(result['errors']['comedian']).to eq 'does not exist'
      end
    end

    it 'it should succeed and return 2 podcasts' do
      user = User.create
      comedian = Comedian.create
      podcast1 = Podcast.create(comedian_ids: [comedian.id])
      podcast2 = Podcast.create(comedian_ids: [comedian.id])

      get :hostedpodcasts, id: comedian.id, access_token: user.access_token

      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['comedian']['id']).to eq comedian.id
      expect(result['podcasts'].count).to eq 2
      expect(result['podcasts'][0]['id']).to eq podcast1.id
      expect(result['podcasts'][1]['id']).to eq podcast2.id
      expect(result['comedian']['is_host']).to eq true
      expect(result['comedian']['is_guest']).to eq false
      expect(result['comedian']['has_standup']).to eq false
    end
  end
  describe 'GET #standuptracks' do
    describe 'it should fail' do
      it 'because the comedian has no tracks' do
        user = User.create
        comedian = Comedian.create

        get :standuptracks, id: comedian.id, access_token: user.access_token

        expect(response.status).to eq 400
        result = JSON.parse(response.body)
        expect(result['success']).to eq false
        expect(result['errors']['comedian']).to eq 'has no standup'
      end

      it 'because the comedian does not exist' do
        user = User.create

        get :standuptracks, id: 0, access_token: user.access_token

        expect(response.status).to eq 400
        result = JSON.parse(response.body)
        expect(result['success']).to eq false
        expect(result['errors']['comedian']).to eq 'does not exist'
      end
    end
    describe 'it should succeed' do
      it 'and return 1 track' do
        user = User.create
        comedian = Comedian.create
        track = Track.create(comedian_id: comedian.id)

        get :standuptracks, id: comedian.id, access_token: user.access_token

        expect(response.status).to eq 200
        result = JSON.parse(response.body)
        expect(result['success']).to eq true
        expect(result['comedian']['has_standup']).to eq true
        expect(result['comedian']['is_guest']).to eq false
        expect(result['comedian']['is_host']).to eq false
        expect(result['tracks'].count).to eq 1
        expect(result['tracks'][0]['id']).to eq track.id
      end
      it 'should succeed and return 2 tracks' do
        user = User.create
        comedian = Comedian.create
        Track.create
        track1 = Track.create(comedian_id: comedian.id)
        track2 = Track.create(comedian_id: comedian.id)

        get :standuptracks, id: comedian.id, access_token: user.access_token

        expect(response.status).to eq 200
        result = JSON.parse(response.body)
        expect(result['success']).to eq true
        expect(result['comedian']['has_standup']).to eq true
        expect(result['comedian']['is_guest']).to eq false
        expect(result['comedian']['is_host']).to eq false
        expect(result['tracks'].count).to eq 2
        expect(result['tracks'][0]['id']).to eq track1.id
        expect(result['tracks'][1]['id']).to eq track2.id
      end
    end
  end

  describe 'GET #info' do
    it 'should succeed' do
      get :info, format: :json, access_token: User.create.access_token
      expect(response.status)
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
    end
  end

  describe 'GET #multiple' do
    it 'should fail because the IDs are missing' do
      get :multiple, format: :json, ids: nil, access_token: User.create.access_token
      expect(response.status).to eq 400
      result = JSON.parse(response.body)
      expect(result['success']).to eq false
      expect(result['errors']['ids']).to eq 'are missing'
    end

    it 'should fail because the IDs do not exist' do
      get :multiple, format: :json, ids: '0, 123456789', access_token: User.create.access_token
      expect(response.status).to eq 400
      result = JSON.parse(response.body)
      expect(result['success']).to eq false
      expect(result['errors']['0']).to eq 'does not exist'
      expect(result['errors']['123456789']).to eq 'does not exist'
    end
    it 'should succeed for one comedian' do
      comedian = Comedian.create
      get :multiple, format: :json, ids: "#{comedian.id}", access_token: User.create.access_token
      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['comedians'].first['id']).to eq comedian.id
    end
    it 'should succeed for two comedians' do
      comedian1 = Comedian.create
      comedian2 = Comedian.create

      get :multiple, format: :json, ids: "#{comedian1.id},   #{comedian2.id}", access_token: User.create.access_token
      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['comedians'].first['id']).to eq comedian1.id
      expect(result['comedians'].second['id']).to eq comedian2.id
    end
  end

  describe 'GET #unsubscribe' do
    it 'should fail because the access token is missing' do
      comedian = Comedian.create
      old_subscribe_count = ComedianSubscription.where(comedian_id: comedian.id, active: true).count
      get :unsubscribe, format: :json, access_token: nil, id: comedian.id
      expect(response.status).to eq 403
      result = JSON.parse(response.body)
      expect(result['success']).to eq false
      expect(result['errors']['access_token']).to eq 'is missing'
      expect(ComedianSubscription.where(active: true).count).to eq old_subscribe_count
    end
    it 'should succeed' do
      user = User.create
      comedian = Comedian.create
      old_subscribe_count = ComedianSubscription.where(active: true, comedian_id: comedian.id).count
      get :unsubscribe, format: :json, access_token: user.access_token, id: comedian.id
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(ComedianSubscription.where(active: true, comedian_id: comedian.id).count).to eq old_subscribe_count
    end
  end

  describe 'GET #subscribe' do
    it 'should fail because the access token is missing' do
      comedian = Comedian.create
      old_subscribe_count = ComedianSubscription.where(comedian_id: comedian.id, active: true).count
      get :subscribe, format: :json, access_token: nil, id: comedian.id
      expect(response.status).to eq 403
      result = JSON.parse(response.body)
      expect(result['success']).to eq false
      expect(result['errors']['access_token']).to eq 'is missing'
      expect(ComedianSubscription.where(active: true).count).to eq old_subscribe_count
    end

    it 'should succeed' do
      comedian = Comedian.create
      user = User.create
      old_subscribe_count = ComedianSubscription.where(user_id: user.id, active: true).count
      get :subscribe, format: :json, access_token: user.access_token, id: comedian.id
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(ComedianSubscription.where(user_id: user.id, active: true).count).to eq (old_subscribe_count + 1)
    end
  end

  describe 'GET #show' do
    it 'should succeed and return and show that the comedian has standup' do
      comedian = Comedian.create
      Track.create(comedian_id: comedian.id)

      get :show, id: comedian.id, access_token: User.create.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['comedian']['id']).to eq comedian.id
      expect(result['comedian']['has_standup']).to eq true
      expect(result['comedian']['is_guest']).to eq false
      expect(result['comedian']['is_host']).to eq false
    end

    it 'should succeed and return and show that the comedian is a guest in a podcast and has standup' do
      comedian = Comedian.create
      Track.create(comedian_id: comedian.id)
      podcast = Podcast.create
      Podcastepisode.create(podcast_id: podcast.id, comedian_ids: [comedian.id])
      get :show, id: comedian.id, access_token: User.create.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['comedian']['id']).to eq comedian.id
      expect(result['comedian']['has_standup']).to eq true
      expect(result['comedian']['is_guest']).to eq true
      expect(result['comedian']['is_host']).to eq false
    end

    it 'should succeed and return and show that the comedian hosts a podcast and has standup' do
      comedian = Comedian.create
      Track.create(comedian_id: comedian.id)
      Podcast.create(comedian_ids: [comedian.id])
      get :show, id: comedian.id, access_token: User.create.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['comedian']['id']).to eq comedian.id
      expect(result['comedian']['has_standup']).to eq true
      expect(result['comedian']['is_guest']).to eq false
      expect(result['comedian']['is_host']).to eq true
    end

    it 'should return status code 400 and success false' do
      get :show, id: 9999999999, access_token: User.create.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 400

      expect(result['success']).to eq false

      expect(result['errors']['9999999999']).to eq 'comedian with id 9999999999 does not exist'
    end
    it 'should return status code 200, success true, and a comedian information' do
      values =
        {
          first_name: 'fnames3', last_name: 'lnames3', middle_name: 'mnames3',
          biography: 'biographys3', website: 'websites3',
          twitter_name: 'twitter_names3', facebook_name: 'facebook_names3',
          instagram_name: 'instagram_names3', profile_picture: '/profile_pictures3'
        }

      comedian = Comedian.create(values)

      get :show, id: comedian.id, access_token: User.create.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 200

      expect(result['success']).to eq true

      res = result['comedian']
      expect(res['id']).to eq comedian.id
      expect(res['first_name']).to eq comedian.first_name
      expect(res['biography']).to eq comedian.biography
      expect(res['website']).to eq comedian.website
      expect(res['twitter_name']).to eq comedian.twitter_name
      expect(res['facebook_name']).to eq comedian.facebook_name
      expect(res['instagram_name']).to eq comedian.instagram_name
      expect(res['profile_picture']).to eq ["#{comedian.profile_picture}"]

    end
  end

  describe 'POST #custom_update' do
    it 'should deny access' do
      user = User.create
      comedian = Comedian.create
      post :custom_update, id: comedian.id, key: 'key', value: 'value', access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 403
      expect(result['success']).to eq false
      expect(result['errors']['user']).to eq 'does not have permission to do this'
    end

    it 'should succeed and return the comedian and show a queued alter value' do
      user = User.create(admin: true)
      comedian = Comedian.create(first_name: 'old', last_name: 'old')

      post :custom_update, id: comedian.id, key: 'first_name', value: 'new', access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      res = Comedian.find_by(id: comedian.id)
      expect(res.id).to eq comedian.id
      expect(res.first_name).to eq 'old'

      change = Change.where(data_type: 'comedian', data_id: comedian.id).last
      expect(change.values['first_name']).to eq 'new'

      get :show, id: comedian.id, access_token: User.create.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['comedian']['id']).to eq comedian.id
      expect(result['comedian']['has_standup']).to eq false
      expect(result['comedian']['is_guest']).to eq false
      expect(result['comedian']['is_host']).to eq false
      expect(result['comedian']['first_name']).to eq 'old'
    end

    it 'should fail to alter a value because it is not allowed' do
      user = User.create(admin: true)
      comedian = Comedian.create(first_name: 'old', last_name: 'old', user_id: 0)

      post :custom_update, id: comedian.id, key: 'user_id', value: user.id, access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 400
      expect(result['success']).to eq false
      res = Comedian.find_by(id: comedian.id)
      expect(res.id).to eq comedian.id
      expect(res.first_name).to eq 'old'
      expect(res.last_name).to eq 'old'
      expect(res.user_id).to eq 0
      expect(result['errors']['params']).to eq 'are missing or incorrect'
    end
  end

  describe 'GET #alter_list' do
    it 'should deny access' do
      user = User.create
      get :alter_list, id: 0, access_token: user.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 403
      expect(result['success']).to eq false
      expect(result['errors']['user']).to eq 'does not have permission to do this'
    end
    it 'should fail because id is not valid' do
      user = User.create(admin: true)
      get :alter_list, id: 0, access_token: user.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 400
      expect(result['success']).to eq false
      expect(result['errors']['parameters']).to eq 'need to be specified'
    end
    it 'should fail because type is not valid' do
      user = User.create(admin: true)
      get :alter_list, id: 1, type: 'wow', access_token: user.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 400
      expect(result['success']).to eq false
      expect(result['errors']['parameters']).to eq 'type can only be add or remove'
    end
    it 'should fail because type is missing' do
      user = User.create(admin: true)
      get :alter_list, id: 1, type: nil, access_token: user.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 400
      expect(result['success']).to eq false
      expect(result['errors']['parameters']).to eq 'need to be specified'
    end
    it 'should add a comedian to the list' do
      key = 'GLOBAL_LISTED_COMEDIANS'
      clear_redis(key)
      user = User.create(admin: true)
      comedian = Comedian.create
      get :alter_list, id: comedian.id, type: 'add', access_token: user.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['comedian']).to eq "with ID #{comedian.id} successfully added"

      get :list, access_token: User.create.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['comedians'].count).to eq 1
      expect(result['comedians'][0]['id']).to eq comedian.id
      ids = get_redis(key).split(',').map(&:to_i)
      expect(ids.count).to eq 1
      expect(ids.first).to eq comedian.id
    end
    it 'should remove a comedian from the list' do
      key = 'GLOBAL_LISTED_COMEDIANS'
      clear_redis(key)
      user = User.create(admin: true)
      comedian = Comedian.create
      get :alter_list, id: comedian.id, type: 'add', access_token: user.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['comedian']).to eq "with ID #{comedian.id} successfully added"

      get :list, access_token: User.create.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['comedians'].count).to eq 1
      expect(result['comedians'][0]['id']).to eq comedian.id
      ids = get_redis(key).split(',').map(&:to_i)
      expect(ids.count).to eq 1
      expect(ids.first).to eq comedian.id

      get :alter_list, id: comedian.id, type: 'remove', access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['comedian']).to eq "with ID #{comedian.id} successfully removed"

      get :list, access_token: User.create.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['comedians'].count).to eq 0
      ids = []
      ids = get_redis(key).split(',').map(&:to_i) if get_redis(key).present?
      expect(ids.count).to eq 0
    end
  end

  describe 'PUT #update' do
    it 'should deny access' do
      user = User.create
      put :update, id: 9999999999, access_token: user.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 403
      expect(result['success']).to eq false
      expect(result['errors']['user']).to eq 'does not have permission to do this'
    end
    it 'should return status code 400 and success false' do
      user = User.create(admin: true)
      put :update, id: 9999999999, access_token: user.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 400
      expect(result['success']).to eq false
      expect(result['errors']["9999999999"]).to eq 'comedian with id 9999999999 does not exist'
    end
    it 'should return status code 200 and success true' do
      user = User.create(admin: true)
      values =
        {
          last_name: "lnames", first_name: 'names', biography: 'biographys', website: 'websites',
          twitter_name: 'twitter_names', facebook_name: 'facebook_names',
          instagram_name: 'instagram_names', profile_picture: '/profile_pictures'
        }

      comedian = Comedian.new(values)
      comedian.save!

      new_values =
        {
          instagram_name: 'instagram_names', profile_picture: '/profile_pictures'
        }

      put :update, id: comedian.id, comedian: new_values, access_token: user.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 200

      res = result['comedian']
      expect(res['id']).to eq comedian.id
      expect(res['first_name']).to eq nil
      expect(res['last_name']).to eq nil
      expect(res['biography']).to eq nil
      expect(res['website']).to eq nil
      expect(res['twitter_name']).to eq nil
      expect(res['facebook_name']).to eq nil
      expect(res['instagram_name']).to eq new_values[:instagram_name]
      expect(res['profile_picture']).to eq ["#{new_values[:profile_picture]}"]
    end
  end

  describe 'PATCH #update' do
    it 'should deny access' do
      user = User.create
      patch :update, id: 9999999999, access_token: user.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 403
      expect(result['success']).to eq false
      expect(result['errors']['user']).to eq 'does not have permission to do this'
    end
    it 'should return status code 400 and success false' do
      user = User.create(admin: true)
      patch :update, id: 9999999999, access_token: user.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 400
      expect(result['success']).to eq false
      expect(result['errors']['9999999999']).to eq 'comedian with id 9999999999 does not exist'
    end

    it 'should return status code 200 and success true' do
      user = User.create(admin: true)
      values =
        {
          last_name: 'names', first_name: 'names', biography: 'biographys', website: 'websites',
          twitter_name: 'twitter_names', facebook_name: 'facebook_names',
          instagram_name: 'instagram_names', profile_picture: '/profile_pictures'
        }

      comedian = Comedian.new(values)
      comedian.save!

      new_values =
        {
          instagram_name: 'instagram_names', profile_picture: '/profile_pictures'
        }

      patch :update, id: comedian.id, comedian: new_values, access_token: user.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 200

      res = result['comedian']
      expect(res['id']).to eq comedian.id
      expect(res['first_name']).to eq values[:first_name]
      expect(res['last_name']).to eq values[:last_name]
      expect(res['biography']).to eq values[:biography]
      expect(res['website']).to eq values[:website]
      expect(res['twitter_name']).to eq values[:twitter_name]
      expect(res['facebook_name']).to eq values[:facebook_name]
      expect(res['instagram_name']).to eq new_values[:instagram_name]
      expect(res['profile_picture']).to eq ["#{new_values[:profile_picture]}"]
    end
  end

  describe 'GET #tracks' do
    it "should be successful" do
      values =
        {
          first_name: 'names', biography: 'biographys', website: 'websites',
          twitter_name: 'twitter_names', facebook_name: 'facebook_names',
          instagram_name: 'instagram_names', profile_picture: '/profile_pictures'
        }
      comedian = Comedian.create(values)

      t1 =
        {
          title: 'title1',
          author: 'author1',
          description: 'description1',
          duration: 100,
          comedian_id: comedian.id,
          high_stream_url: '/stream_url1.mp3'
        }

      t2 =
        {
          title: 'title2',
          author: 'author2',
          description: 'description2',
          duration: 100,
          comedian_id: comedian.id,
          high_stream_url: '/stream_url2.mp3'
        }

      old_count = Track.count
      track1 = Track.create(t1)
      track2 = Track.create(t2)

      expect(Track.count).to eq (old_count + 2)

      get :tracks, format: :json, id: comedian.id, access_token: User.create.access_token

      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['comedian']).not_to be nil
      expect(result['comedian']['id']).to eq comedian.id
      expect(result['comedian']['first_name']).to eq comedian.first_name
      expect(result['comedian']['biography']).to eq comedian.biography
      expect(result['comedian']['website']).to eq comedian.website
      expect(result['comedian']['twitter_name']).to eq comedian.twitter_name
      expect(result['comedian']['facebook_name']).to eq comedian.facebook_name
      expect(result['comedian']['instagram_name']).to eq comedian.instagram_name
      expect(result['comedian']['profile_picture']).to eq comedian.proper_profile_picture
      expect(result['count']).to eq 2
      expect(result['tracks'].first['title']).to eq track1.title
      expect(result['tracks'].last['title']).to eq track2.title
    end
    it 'should be unsuccessful because the comedian does not exist' do
      get :tracks, format: :json, id: 1111111, access_token: User.create.access_token

      expect(response.status).to eq 400
      result = JSON.parse(response.body)
      expect(result['errors']).to_not be nil
      expect(result['success']).to eq false
      expect(result['errors']['comedian']).to eq 'does not exist'
    end
  end

  describe 'GET #all' do
    it 'should return all of the comedians' do
      values1 =
        {
          first_name: 'names', biography: 'biographys', website: 'websites',
          twitter_name: 'twitter_names', facebook_name: 'facebook_names',
          instagram_name: 'instagram_names', profile_picture: '/profile_pictures',
          staging_only: false
        }
      comedian1 = Comedian.create(values1)

      values2 =
        {
          first_name: 'names', biography: 'biographys', website: 'websites',
          twitter_name: 'twitter_names', facebook_name: 'facebook_names',
          instagram_name: 'instagram_names', profile_picture: '/profile_pictures',
          staging_only: false
        }
      comedian2 = Comedian.create(values2)
      Track.create(comedian_id: comedian1.id)
      Track.create(comedian_id: comedian2.id)
      get :all, format: :json, access_token: User.create.access_token

      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['comedians']).to_not be nil
      expect(result['comedians'].first['id']).to eq comedian1.id
      expect(result['comedians'].first['biography']).to eq comedian1.biography
      expect(result['comedians'].first['profile_picture']).to eq comedian1.proper_profile_picture
      expect(result['comedians'].last['id']).to eq comedian2.id
      expect(result['comedians'].last['biography']).to eq comedian2.biography
      expect(result['comedians'].last['profile_picture']).to eq comedian2.proper_profile_picture
    end
  end

  describe 'GET #info' do
    it 'should return status code 200 and success true' do
      get :info, format: :json, access_token: User.create.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
    end
  end
end
