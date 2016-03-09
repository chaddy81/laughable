require 'rails_helper'
require 'database_cleaner'

RSpec.describe V1::TracksController, type: :controller do
  render_views

  describe 'GET #custom_update' do
    it 'should deny access' do
      user = User.create
      post :custom_update, id: 0, key: 'key', value: 'value', access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 403
      expect(result['success']).to eq false
      expect(result['errors']['user']).to eq 'does not have permission to do this'
    end
    it 'should show the queued up changes for a value' do
      user = User.create(admin: true)
      track = Track.create(title: 'old')
      post :custom_update, id: track.id, key: 'title', value: 'new', access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      res = Track.find_by(id: track.id)
      expect(res.id).to eq track.id
      expect(res.title).to eq 'old'
      change = Change.where(data_type: 'track', data_id: track.id).last
      expect(change.values['title']).to eq 'new'
    end

    it 'should fail when altering an unallowed value' do
      user = User.create(admin: true)
      track = Track.create(title: 'old')
      post :custom_update, id: track.id, key: 'name', value: 'new', access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 400
      expect(result['success']).to eq false
      expect(result['errors']['params']).to eq 'are missing or incorrect'
    end
  end
  describe 'GET #show' do
    it 'and the track does not exist' do
      get :show, format: :json, id: 111111111, access_token: User.create.access_token

      expect(response.status).to eq 400
      result = JSON.parse(response.body)
      expect(result['success']).to eq false
      expect(result['errors']['111111111']).to eq 'the track with id 111111111 does not exist'
    end
    it 'and the track exists' do
      comedian_values =
        {
          first_name: 'comedian_name',
          biography: 'biography',
          website: 'website',
          twitter_name: 'twitter_name',
          facebook_name: 'facebook_name',
          instagram_name: 'instagram_name',
          profile_picture: '/profile_picture'
        }
      comedian = Comedian.create(comedian_values)
      values1 =
        {
          title: 'title',
          author: 'author',
          description: 'description',
          duration: 100,
          comedian_id: comedian.id,
          high_stream_url: '/stream_url.mp3',
          medium_stream_url: '/stream_url.mp3',
          low_stream_url: '/stream_url.mp3'
        }

      track1 = Track.create(values1)

      get :show, format: :json, id: track1.id, access_token: User.create.access_token

      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['track']['id']).to eq track1.id
      expect(result['track']['comedian']['id']).to eq track1.comedian.id
      expect(result['track']['comedian']['profile_picture']).to eq track1.comedian.proper_profile_picture
      expect(result['track']['high_stream_url']).to eq track1.proper_high_stream_url
      expect(result['track']['medium_stream_url']).to eq track1.proper_medium_stream_url
      expect(result['track']['low_stream_url']).to eq track1.proper_low_stream_url
    end
    describe 'when custom_update is used' do
      it 'should correctly show the right comedian information' do
        user = User.create(admin: true)
        track = Track.create(title: 'old')
        comedian = Comedian.create
        post :custom_update, id: track.id, key: 'comedian_id', value: comedian.id.to_s, access_token: user.access_token
        result = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(result['success']).to eq true
        res = Track.find_by(id: track.id)
        expect(res.id).to eq track.id
        expect(res.title).to eq 'old'
        expect(res.comedian_id).to eq nil
        change = Change.where(data_type: 'track', data_id: track.id).last
        expect(change.values['comedian_id']).to eq comedian.id.to_s
        get :show, format: :json, id: track.id, access_token: User.create.access_token
        result = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(result['success']).to eq true
        expect(result['track']['id']).to eq track.id
        expect(result['track']['comedian']['id']).to eq comedian.id
      end
    end
  end

  describe 'GET #all' do
    it 'should return status code 400 and success false' do
      # Delete any tracks that might be present to make sure there are no tracks
      # that could be sent to someone
      Track.all.map(&:delete)

      get :all, format: :json, access_token: User.create.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 400
      expect(result['errors']['tracks']).to eq 'there are no tracks'
    end

    it 'should return status code 200 and success true' do
      values =
        {
          title: 'title',
          author: 'author',
          description: 'description',
          duration: 100,
          comedian_id: 1,
          high_stream_url: '/stream_url.mp3',
          medium_stream_url: '/stream_url.mp3',
          low_stream_url: '/stream_url.mp3',
          staging_only: false
        }

      track = Track.create(values)

      get :all, format: :json, access_token: User.create.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['errors']).to eq nil
      expect(result['tracks']).to_not eq nil
      tracks = result['tracks']
      expect(tracks.class).to eq Array
      expect(tracks.first['id']).to eq track.id
      expect(tracks.first['title']).to eq track.title
      expect(tracks.first['author']).to eq track.author
      expect(tracks.first['description']).to eq track.description
      expect(tracks.first['duration']).to eq track.duration
      expect(tracks.first['high_stream_url']).to eq track.proper_high_stream_url
      expect(tracks.first['medium_stream_url']).to eq track.proper_medium_stream_url
      expect(tracks.first['low_stream_url']).to eq track.proper_low_stream_url
      expect(tracks.first['comedian_id']).to eq track.comedian_id
    end
  end

  describe 'GET #multiple' do
    it 'and the ids are missing' do
      get :multiple, format: :json, ids: nil, access_token: User.create.access_token

      expect(response.status).to eq 400
      result = JSON.parse(response.body)
      expect(result['errors']['ids']).to eq 'are missing'
    end

    it 'and one track exists while the other does not' do
      comedian_values =
        {
          first_name: 'comedian_name',
          biography: 'biography',
          website: 'website',
          twitter_name: 'twitter_name',
          facebook_name: 'facebook_name',
          instagram_name: 'instagram_name',
          profile_picture: '/profile_picture'
        }
      comedian = Comedian.create(comedian_values)

      values1 =
        {
          title: 'title',
          author: 'author',
          description: 'description',
          duration: 100,
          comedian_id: comedian.id,
          high_stream_url: '/stream_url.mp3',
          medium_stream_url: '/stream_url.mp3',
          low_stream_url: '/stream_url.mp3'
        }

      track1 = Track.create(values1)

      get :multiple, format: :json, ids: "1111, #{track1.id}", access_token: User.create.access_token

      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['tracks']).to_not be nil
      expect(result['errors']).to_not be nil
      expect(result['tracks'].first['id']).to eq track1.id
      expect(result['tracks'].first['high_stream_url']).to eq track1.proper_high_stream_url
      expect(result['tracks'].first['medium_stream_url']).to eq track1.proper_medium_stream_url
      expect(result['tracks'].first['low_stream_url']).to eq track1.proper_low_stream_url
      expect(result['tracks'].first['comedian']['id']).to eq track1.comedian.id
      expect(result['tracks'].first['comedian']['profile_picture']).to eq track1.comedian.proper_profile_picture
      expect(result['errors']['1111']).to eq "does not exist"

    end

    it 'and the tracks do not exist' do
      get :multiple, format: :json, ids: '111111, 222222', access_token: User.create.access_token

      expect(response.status).to eq 400
      result = JSON.parse(response.body)
      expect(result['errors']['111111']).to eq 'does not exist'
      expect(result['errors']['222222']).to eq 'does not exist'
    end
    it 'and it returns two tracks' do
      t1 =
        {
          title: 'title1',
          author: 'author1',
          description: 'description1',
          duration: 100,
          comedian_id: 1,
          high_stream_url: '/stream_url1.mp3',
          medium_stream_url: '/stream_url1.mp3',
          low_stream_url: '/stream_url1.mp3'
        }

      t2 =
        {
          title: 'title2',
          author: 'author2',
          description: 'description2',
          duration: 100,
          comedian_id: 1,
          high_stream_url: '/stream_url2.mp3',
          medium_stream_url: '/stream_url2.mp3',
          low_stream_url: '/stream_url2.mp3'

        }

      old_count = Track.count
      track1 = Track.create(t1)
      track2 = Track.create(t2)

      expect(Track.count).to eq (old_count + 2)

      get :multiple, format: :json, ids: "#{track1.id}, #{track2.id}", access_token: User.create.access_token

      expect(response.status).to eq 200
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
