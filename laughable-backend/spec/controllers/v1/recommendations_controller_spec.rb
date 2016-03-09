require 'rails_helper'

RSpec.describe V1::RecommendationsController, type: :controller do

  def set_redis_with_values(key, values_array)
    $redis.with do |conn|
      input = values_array.join(',')
      conn.set(key, input)
    end
  end

  def get_redis_arr_values(key)
    res = []
    $redis.with do |conn|
      res = conn.get(key).split(',')
    end
  end

  def clear_redis_with_values(key)
    $redis.with { |conn| conn.del(key) }
  end

  def set_redis_comedian_recommendations
    $redis.with do |conn|
      input = {}
      Comedian.pluck(:id).each do |id|
        input[id] = 0
      end
      conn.set('comedian_playlist_global', input.to_json)
    end
  end

  def set_redis_next_recommendations
    $redis.with do |conn|
      input = {}
      Track.pluck(:id).each do |id|
        input[id] = 0
      end
      conn.set('next_playlist_global', input.to_json)
    end
  end

  describe 'GET #schedule_release' do
    it 'should fail because of lack of permissions' do
      user = User.create
      get :schedule_release, format: :json, access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 403
      expect(result['success']).to eq false
      expect(result['errors']['user']).to eq 'does not have permission to do this'
    end
    it 'should perform a release and alter tracks' do
      user = User.create(admin: true)
      comedian = Comedian.create(first_name: 'fold', last_name: 'lold')
      comedian2 = Comedian.create
      track = Track.create(title: 'old', comedian_id: comedian.id)
      podcast = Podcast.create(title: 'old', comedian_ids: [comedian.id])
      episode = Podcastepisode.create(title: 'old', podcast_id: podcast.id, comedian_ids: [comedian.id])

      Change.create(data_type: 'comedian', data_id: comedian.id, values: { first_name: 'fnew' })
      Change.create(data_type: 'comedian', data_id: comedian.id, values: { last_name: 'lnew' })
      Change.create(data_type: 'track', data_id: track.id, values: { title: 'new' })
      Change.create(data_type: 'track', data_id: track.id, values: { comedian_id: comedian2.id })
      Change.create(data_type: 'podcast', data_id: podcast.id, values: { comedian_ids: [comedian.id, comedian2.id] })
      Change.create(data_type: 'podcast', data_id: podcast.id, values: { title: 'new' })
      Change.create(data_type: 'episode', data_id: episode.id, values: { title: 'new' })
      Change.create(data_type: 'episode', data_id: episode.id, values: { comedian_ids: [comedian.id, comedian2.id] })

      get :schedule_release, format: :json, access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      comedian.reload
      track.reload
      podcast.reload
      episode.reload
      expect(comedian.first_name).to eq 'fnew'
      expect(comedian.last_name).to eq 'lnew'
      expect(track.title).to eq 'new'
      expect(track.comedian_id).to eq comedian2.id
      expect(podcast.title).to eq 'new'
      expect(podcast.comedian_ids).to eq [comedian.id, comedian2.id]
      expect(episode.comedian_ids).to eq [comedian.id, comedian2.id]
      expect(episode.title).to eq 'new'
    end
  end

  describe 'GET #up_next_list' do
    it 'should fail because of lack of permissions' do
      user = User.create
      get :up_next_list, format: :json, access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 403
      expect(result['success']).to eq false
      expect(result['errors']['user']).to eq 'does not have permission to do this'
    end
    it 'should succeed and return 15 tracks' do
      user = User.create(admin: true)
      track_ids = []
      20.times do
        track = Track.create
        track_ids << track.id
      end
      $redis.with do |conn|
        conn.del('next_playlist_global')
        conn.del("next_playlist_for_user-#{user.id}")
        conn.set('next_playlist_global', track_ids.join(','))
      end
      get :up_next_list, format: :json, access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['tracks'].count).to eq 20
      expect(result['tracks'][0]['id']).to eq track_ids[0]
    end
    it 'should succeed and return 1 track' do
      user = User.create(admin: true)
      track = Track.create
      $redis.with do |conn|
        conn.del('next_playlist_global')
        conn.set('next_playlist_global', "#{track.id}")
      end
      get :up_next_list, format: :json, access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['tracks'].count).to eq 1
      expect(result['tracks'][0]['id']).to eq track.id
    end
  end

  describe 'GET #alter_podcastepisode' do
    describe 'it should succeed' do
      it 'a previous order gets overwritten' do
        key = 'GLOBAL_PODCAST_EPISODE_SUGGESTION'
        $redis.with do |c|
          c.del(key)
          c.set(key, "4444,55555")
        end
        user = User.create(admin: true)
        comedian = Comedian.create
        podcast1 = Podcast.create(comedian_ids: [comedian.id])
        podcast2 = Podcast.create(comedian_ids: [comedian.id])
        episode1 = Podcastepisode.create(podcast_id: podcast1.id)
        episode2 = Podcastepisode.create(podcast_id: podcast2.id)
        input = "#{episode1.id}, #{episode2.id}"
        get :alter_podcastepisode, format: :json, access_token: user.access_token, input: input
        result = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(result['success']).to eq true
        expect(result['episodes'].count).to eq 2
        expect(result['episodes'][0]['id']).to eq episode1.id
        expect(result['episodes'][1]['id']).to eq episode2.id
        expect(result['episodes'][0]['podcast']['id']).to eq podcast1.id
        expect(result['episodes'][1]['podcast']['id']).to eq podcast2.id
        expect(result['episodes'][0]['podcast']['hosts'][0]['id']).to eq comedian.id
        expect(result['episodes'][1]['podcast']['hosts'][0]['id']).to eq comedian.id
      end
      it 'when specifying a new episodes when no previous ones exist' do
        key = 'GLOBAL_PODCAST_EPISODE_SUGGESTION'
        $redis.with do |c|
          c.del(key)
        end
        user = User.create(admin: true)
        comedian = Comedian.create
        podcast1 = Podcast.create(comedian_ids: [comedian.id])
        podcast2 = Podcast.create(comedian_ids: [comedian.id])
        episode1 = Podcastepisode.create(podcast_id: podcast1.id)
        episode2 = Podcastepisode.create(podcast_id: podcast2.id)

        input = "#{episode1.id}, #{episode2.id}"
        get :alter_podcastepisode, format: :json, access_token: user.access_token, input: input
        result = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(result['success']).to eq true
        expect(result['episodes'].count).to eq 2
        expect(result['episodes'][0]['id']).to eq episode1.id
        expect(result['episodes'][1]['id']).to eq episode2.id
        expect(result['episodes'][0]['podcast']['id']).to eq podcast1.id
        expect(result['episodes'][1]['podcast']['id']).to eq podcast2.id
        expect(result['episodes'][0]['podcast']['hosts'][0]['id']).to eq comedian.id
        expect(result['episodes'][1]['podcast']['hosts'][0]['id']).to eq comedian.id
      end
    end
    describe 'it should fail' do
      it 'because the user is not an admin' do
        user = User.create
        get :alter_podcastepisode, format: :json, access_token: user.access_token
        result = JSON.parse(response.body)
        expect(response.status).to eq 403
        expect(result['success']).to eq false
        expect(result['errors']['user']).to eq 'does not have permission to do this'
      end

      it 'because podcast episode ids are not present' do
        user = User.create(admin: true)
        get :alter_podcastepisode, format: :json, access_token: user.access_token
        result = JSON.parse(response.body)
        expect(response.status).to eq 400
        expect(result['success']).to eq false
        expect(result['errors']['ids']).to eq 'are missing'
      end

      it 'because one podcast episode id is invalid' do
        user = User.create(admin: true)
        comedian = Comedian.create
        podcast = Podcast.create(comedian_ids: [comedian.id])
        episode = Podcastepisode.create(podcast_id: podcast.id)
        get :alter_podcastepisode, format: :json, access_token: user.access_token, input: "0,#{episode.id}"
        result = JSON.parse(response.body)
        expect(response.status).to eq 400
        expect(result['success']).to eq false
        expect(result['errors']['id']).to eq 'one or more ids are invalid'
      end
    end
  end

  describe 'GET #alter_podcastepisode' do
    describe 'it should succeed' do
      it 'a previous order gets overwritten' do
        key = 'GLOBAL_POPULAR_EPISODE_SUGGESTION'
        $redis.with do |c|
          c.del(key)
          c.set(key, "4444,55555")
        end
        user = User.create(admin: true)
        comedian = Comedian.create
        podcast1 = Podcast.create(comedian_ids: [comedian.id])
        podcast2 = Podcast.create(comedian_ids: [comedian.id])
        episode1 = Podcastepisode.create(podcast_id: podcast1.id)
        episode2 = Podcastepisode.create(podcast_id: podcast2.id)
        input = "#{episode1.id}, #{episode2.id}"
        get :alter_popularepisodes, format: :json, access_token: user.access_token, input: input
        result = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(result['success']).to eq true
        expect(result['episodes'].count).to eq 2
        expect(result['episodes'][0]['id']).to eq episode1.id
        expect(result['episodes'][1]['id']).to eq episode2.id
        expect(result['episodes'][0]['podcast']['id']).to eq podcast1.id
        expect(result['episodes'][1]['podcast']['id']).to eq podcast2.id
        expect(result['episodes'][0]['podcast']['hosts'][0]['id']).to eq comedian.id
        expect(result['episodes'][1]['podcast']['hosts'][0]['id']).to eq comedian.id
      end
      it 'when specifying a new episodes when no previous ones exist' do
        key = 'GLOBAL_POPULAR_EPISODE_SUGGESTION'
        $redis.with do |c|
          c.del(key)
        end
        user = User.create(admin: true)
        comedian = Comedian.create
        podcast1 = Podcast.create(comedian_ids: [comedian.id])
        podcast2 = Podcast.create(comedian_ids: [comedian.id])
        episode1 = Podcastepisode.create(podcast_id: podcast1.id)
        episode2 = Podcastepisode.create(podcast_id: podcast2.id)

        input = "#{episode1.id}, #{episode2.id}"
        get :alter_popularepisodes, format: :json, access_token: user.access_token, input: input
        result = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(result['success']).to eq true
        expect(result['episodes'].count).to eq 2
        expect(result['episodes'][0]['id']).to eq episode1.id
        expect(result['episodes'][1]['id']).to eq episode2.id
        expect(result['episodes'][0]['podcast']['id']).to eq podcast1.id
        expect(result['episodes'][1]['podcast']['id']).to eq podcast2.id
        expect(result['episodes'][0]['podcast']['hosts'][0]['id']).to eq comedian.id
        expect(result['episodes'][1]['podcast']['hosts'][0]['id']).to eq comedian.id
      end
    end
    describe 'it should fail' do
      it 'because the user is not an admin' do
        user = User.create
        get :alter_popularepisodes, format: :json, access_token: user.access_token
        result = JSON.parse(response.body)
        expect(response.status).to eq 403
        expect(result['success']).to eq false
        expect(result['errors']['user']).to eq 'does not have permission to do this'
      end

      it 'because podcast episode ids are not present' do
        user = User.create(admin: true)
        get :alter_popularepisodes, format: :json, access_token: user.access_token
        result = JSON.parse(response.body)
        expect(response.status).to eq 400
        expect(result['success']).to eq false
        expect(result['errors']['ids']).to eq 'are missing'
      end

      it 'because one podcast episode id is invalid' do
        user = User.create(admin: true)
        comedian = Comedian.create
        podcast = Podcast.create(comedian_ids: [comedian.id])
        episode = Podcastepisode.create(podcast_id: podcast.id)
        get :alter_popularepisodes, format: :json, access_token: user.access_token, input: "0,#{episode.id}"
        result = JSON.parse(response.body)
        expect(response.status).to eq 400
        expect(result['success']).to eq false
        expect(result['errors']['id']).to eq 'one or more ids are invalid'
      end
    end
  end


  describe 'GET #alter_up_next' do
    describe 'it should fail' do
      it 'because the user is not an admin' do
        user = User.create
        get :alter_up_next, format: :json, access_token: user.access_token
        result = JSON.parse(response.body)
        expect(response.status).to eq 403
        expect(result['success']).to eq false
        expect(result['errors']['user']).to eq 'does not have permission to do this'
      end
      it 'because a track id is not present' do
        user = User.create(admin: true)
        get :alter_up_next, format: :json, access_token: user.access_token, type: 'remove'
        result = JSON.parse(response.body)
        expect(response.status).to eq 400
        expect(result['success']).to eq false
        expect(result['errors']['id']).to eq 'must be present'
      end
      it 'because position must be present' do
        user = User.create(admin: true)
        track = Track.create
        get :alter_up_next, format: :json, access_token: user.access_token, type: 'insert', id: track.id
        result = JSON.parse(response.body)
        expect(response.status).to eq 400
        expect(result['success']).to eq false
        expect(result['errors']['position']).to eq 'must be present'
      end
    end
    describe 'it should succeed' do
      it 'when removing a track' do
        user = User.create(admin: true)
        track1 = Track.create
        track2 = Track.create
        track3 = Track.create
        track_ids = [track1.id, track2.id, track3.id]
        set_redis_with_values('next_playlist_global', track_ids)
        set_redis_with_values("next_playlist_for_user-#{user.id}", track_ids)

        get :alter_up_next, format: :json, access_token: user.access_token, type: 'remove', id: track1.id

        expect(response.status).to eq 200
        expect(JSON.parse(response.body)['success']).to eq true
        res_global = get_redis_arr_values('next_playlist_global')
        res_user = get_redis_arr_values("next_playlist_for_user-#{user.id}")
        expect(res_global[0]).to eq track2.id.to_s
        expect(res_global[1]).to eq track3.id.to_s
        expect(res_global[2]).to eq track1.id.to_s
        expect(res_user[0]).to eq track2.id.to_s
        expect(res_user[1]).to eq track3.id.to_s
        expect(res_user[2]).to eq track1.id.to_s
        clear_redis_with_values('next_playlist_global')
        clear_redis_with_values("next_playlist_forU-user-#{user.id}")
      end
      it 'when inserting a track into first place' do
        user = User.create(admin: true)
        track1 = Track.create
        track2 = Track.create
        track3 = Track.create
        track_ids = [track1.id, track2.id, track3.id]
        set_redis_with_values('next_playlist_global', track_ids)
        set_redis_with_values("next_playlist_for_user-#{user.id}", track_ids)
        get :alter_up_next, format: :json, access_token: user.access_token, type: 'insert', id: track3.id, position: 1
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)['success']).to eq true
        res_global = get_redis_arr_values('next_playlist_global')
        res_user = get_redis_arr_values("next_playlist_for_user-#{user.id}")
        expect(res_global[0]).to eq track3.id.to_s
        expect(res_global[1]).to eq track1.id.to_s
        expect(res_global[2]).to eq track2.id.to_s
        expect(res_user[0]).to eq track3.id.to_s
        expect(res_user[1]).to eq track1.id.to_s
        expect(res_user[2]).to eq track2.id.to_s
        clear_redis_with_values('next_playlist_global')
        clear_redis_with_values("next_playlist_for-user-#{user.id}")
      end
      it 'when moving a track from first place to second place' do
        user = User.create(admin: true)
        track1 = Track.create
        track2 = Track.create
        track3 = Track.create
        track_ids = [track1.id, track2.id, track3.id]
        set_redis_with_values('next_playlist_global', track_ids)
        set_redis_with_values("next_playlist_for_user-#{user.id}", track_ids)
        get :alter_up_next, format: :json, access_token: user.access_token, type: 'insert', id: track1.id, position: 2
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)['success']).to eq true
        res_global = get_redis_arr_values('next_playlist_global')
        res_user = get_redis_arr_values("next_playlist_for_user-#{user.id}")
        expect(res_global[0]).to eq track2.id.to_s
        expect(res_global[1]).to eq track1.id.to_s
        expect(res_global[2]).to eq track3.id.to_s
        expect(res_user[0]).to eq track2.id.to_s
        expect(res_user[1]).to eq track1.id.to_s
        expect(res_user[2]).to eq track3.id.to_s
        clear_redis_with_values('next_playlist_global')
        clear_redis_with_values("next_playlist_forU-user-#{user.id}")
      end
    end
  end

  describe 'GET #alter' do
    describe 'it should fail' do
      it 'because type is not specified' do
        user = User.create(admin: true)
        get :alter, format: :json, ids: "1,2,3", access_token: user.access_token
        expect(response.status).to eq 400
        result = JSON.parse(response.body)
        expect(result['success']).to eq false
        expect(result['errors']['type']).to eq 'is missing'
      end
      it 'because ids are not specified' do
        user = User.create(admin: true)
        get :alter, format: :json, type: 'long', access_token: user.access_token
        expect(response.status).to eq 400
        result = JSON.parse(response.body)
        expect(result['success']).to eq false
        expect(result['errors']['ids']).to eq 'are missing'
      end
      it 'because an id is invalid' do
        user = User.create(admin: true)
        track = Track.create
        get :alter, format: :json, type: 'long', input: "#{track.id}, 33333333", access_token: user.access_token
        expect(response.status).to eq 400
        result = JSON.parse(response.body)
        expect(result['success']).to eq false
        expect(result['errors']['id']).to eq 'one or more ids are invalid'
      end
    end
    describe 'it should succeed' do
      it 'for short type of tracks' do
        key = 'GLOBAL_SHORT_TRACK_SUGGESTION'
        clear_redis_with_values(key)
        user = User.create(admin: true)
        track1 = Track.create
        track2 = Track.create

        get :alter, format: :json, type: 'short', input: "#{track2.id}, #{track1.id}", access_token: user.access_token

        expect(response.status).to eq 200
        result = JSON.parse(response.body)

        expect(result['success']).to eq true
        expect(result['tracks']).not_to be nil


        values = []
        $redis.with do |conn|
          values = conn.get(key).split(',').map(&:to_i)
        end

        expect(values.class).to eq Array
        expect(values.first).to eq track2.id
        expect(values.last).to eq track1.id
        expect(values.count).to eq 2
      end
      it 'for short type of tracks' do
        key = 'GLOBAL_LONG_TRACK_SUGGESTION'
        clear_redis_with_values(key)
        user = User.create(admin: true)
        track1 = Track.create
        track2 = Track.create

        get :alter, format: :json, type: 'long', input: "#{track2.id}, #{track1.id}", access_token: user.access_token

        expect(response.status).to eq 200
        result = JSON.parse(response.body)

        expect(result['success']).to eq true
        expect(result['tracks']).not_to be nil


        values = []
        $redis.with do |conn|
          values = conn.get(key).split(',').map(&:to_i)
        end

        expect(values.class).to eq Array
        expect(values.first).to eq track2.id
        expect(values.last).to eq track1.id
        expect(values.count).to eq 2
      end
      it 'for short type of tracks' do
        key = 'GLOBAL_RECOMMENDED_TRACK_SUGGESTION'
        clear_redis_with_values(key)
        user = User.create(admin: true)
        track1 = Track.create
        track2 = Track.create

        get :alter, format: :json, type: 'recommended', input: "#{track2.id}, #{track1.id}", access_token: user.access_token

        expect(response.status).to eq 200
        result = JSON.parse(response.body)

        expect(result['success']).to eq true
        expect(result['tracks']).not_to be nil

        values = []
        $redis.with do |conn|
          values = conn.get(key).split(',').map(&:to_i)
        end

        expect(values.class).to eq Array
        expect(values.first).to eq track2.id
        expect(values.last).to eq track1.id
        expect(values.count).to eq 2
      end
    end
  end
  describe 'GET #info' do
    it 'should return status 403 because user is not admin' do
      get :info, format: :json

      result = JSON.parse(response.body)
      expect(response.status).to eq 403
      expect(result['success']).to eq false
    end
    it 'should return status 200 and success true' do
      user = User.create(admin: true)
      get :info, format: :json, access_token: user.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
    end
  end

  describe 'GET #long' do
    it 'should fail because tracks do not exist' do
      user = User.create
      clear_redis_with_values('GLOBAL_LONG_TRACK_SUGGESTION')
      get :long, format: :json, access_token: user.access_token

      expect(response.status).to eq 400
      result = JSON.parse(response.body)
      expect(result['success']).to eq false
      expect(result['errors']['tracks']).to eq 'are not specified'
    end
    it 'should return and be successful' do
      comedian = Comedian.create
      track1 = Track.create(comedian_id: comedian.id)
      track2 = Track.create(comedian_id: comedian.id)
      user = User.create

      entries = [track1.id, track2.id]
      set_redis_with_values('GLOBAL_LONG_TRACK_SUGGESTION', entries)

      get :long, format: :json, access_token: user.access_token

      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['tracks'].first['id']).to eq track1.id
      expect(result['tracks'].last['id']).to eq track2.id
      expect(result['tracks'].first['comedian']['id']).to eq comedian.id
      expect(result['tracks'].last['comedian']['id']).to eq comedian.id
      clear_redis_with_values('GLOBAL_LONG_TRACK_SUGGESTION')
    end
  end

  describe 'GET #recommended' do
    it 'should fail because tracks do not exist' do
      user = User.create
      clear_redis_with_values('GLOBAL_RECOMMENDED_TRACK_SUGGESTION')
      get :recommended, format: :json, access_token: user.access_token

      expect(response.status).to eq 400
      result = JSON.parse(response.body)
      expect(result['success']).to eq false
      expect(result['errors']['tracks']).to eq 'are not specified'
    end

    it 'should return and be successful' do
      comedian = Comedian.create
      track1 = Track.create(comedian_id: comedian.id)
      track2 = Track.create(comedian_id: comedian.id)
      user = User.create

      entries = [track1.id, track2.id]
      set_redis_with_values('GLOBAL_RECOMMENDED_TRACK_SUGGESTION', entries)

      get :recommended, format: :json, access_token: user.access_token

      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['tracks'].first['id']).to eq track1.id
      expect(result['tracks'].last['id']).to eq track2.id
      expect(result['tracks'].first['comedian']['id']).to eq comedian.id
      expect(result['tracks'].last['comedian']['id']).to eq comedian.id
      clear_redis_with_values('GLOBAL_RECOMMENDED_TRACK_SUGGESTION')
    end
  end

  describe 'GET #podcastepisode' do
    it 'should fail because episodes are not set' do
      user = User.create
      clear_redis_with_values('GLOBAL_PODCAST_EPISODE_SUGGESTION')
      get :podcastepisode, format: :json, access_token: user.access_token
      expect(response.status).to eq 400
      result = JSON.parse(response.body)
      expect(result['success']).to eq false
      expect(result['errors']['episodes']).to eq 'are not specified'
    end
    it 'should succeed and return 2 episodes' do
      user = User.create
      key = 'GLOBAL_PODCAST_EPISODE_SUGGESTION'
      clear_redis_with_values(key)
      comedian = Comedian.create
      podcast1 = Podcast.create(comedian_ids: [comedian.id])
      podcast2 = Podcast.create(comedian_ids: [comedian.id])
      episode1 = Podcastepisode.create(podcast_id: podcast1.id)
      episode2 = Podcastepisode.create(podcast_id: podcast2.id)
      episode3 = Podcastepisode.create(podcast_id: podcast2.id)
      set_redis_with_values(key, [episode1.id, episode2.id])

      get :podcastepisode, format: :json, access_token: user.access_token
      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['episodes'].count).to eq 2
      expect(result['episodes'][0]['id']).to eq episode1.id
      expect(result['episodes'][0]['podcast']['id']).to eq podcast1.id
      expect(result['episodes'][1]['podcast']['id']).to eq podcast2.id
      expect(result['episodes'][0]['podcast']['hosts'][0]['id']).to eq comedian.id
      expect(result['episodes'][1]['podcast']['hosts'][0]['id']).to eq comedian.id
      expect(result['episodes'][1]['id']).to eq episode2.id
      expect(Podcastepisode.count).to eq 3
      expect(Podcastepisode.last.id).to eq episode3.id
    end
  end

  describe 'GET #popularepisodes' do
    it 'should fail because episodes are not set' do
      user = User.create
      clear_redis_with_values('GLOBAL_POPULAR_EPISODE_SUGGESTION')
      get :popularepisodes, format: :json, access_token: user.access_token
      expect(response.status).to eq 400
      result = JSON.parse(response.body)
      expect(result['success']).to eq false
      expect(result['errors']['episodes']).to eq 'are not specified'
    end
    it 'should succeed and return 2 episodes' do
      user = User.create
      key = 'GLOBAL_POPULAR_EPISODE_SUGGESTION'
      clear_redis_with_values(key)
      comedian = Comedian.create
      podcast1 = Podcast.create(comedian_ids: [comedian.id])
      podcast2 = Podcast.create(comedian_ids: [comedian.id])
      episode1 = Podcastepisode.create(podcast_id: podcast1.id)
      episode2 = Podcastepisode.create(podcast_id: podcast2.id)
      episode3 = Podcastepisode.create(podcast_id: podcast2.id)
      set_redis_with_values(key, [episode1.id, episode2.id])

      get :popularepisodes, format: :json, access_token: user.access_token
      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['episodes'].count).to eq 2
      expect(result['episodes'][0]['id']).to eq episode1.id
      expect(result['episodes'][0]['podcast']['id']).to eq podcast1.id
      expect(result['episodes'][1]['podcast']['id']).to eq podcast2.id
      expect(result['episodes'][0]['podcast']['hosts'][0]['id']).to eq comedian.id
      expect(result['episodes'][1]['podcast']['hosts'][0]['id']).to eq comedian.id
      expect(result['episodes'][1]['id']).to eq episode2.id
      expect(Podcastepisode.count).to eq 3
      expect(Podcastepisode.last.id).to eq episode3.id
    end
  end

  describe 'GET #short' do
    it 'should fail because tracks do not exist' do
      user = User.create
      clear_redis_with_values('GLOBAL_SHORT_TRACK_SUGGESTION')
      get :short, format: :json, access_token: user.access_token
      expect(response.status).to eq 400
      result = JSON.parse(response.body)
      expect(result['success']).to eq false
      expect(result['errors']['tracks']).to eq 'are not specified'
    end

    it 'should return and be successful' do
      comedian = Comedian.create
      track1 = Track.create(comedian_id: comedian.id)
      track2 = Track.create(comedian_id: comedian.id)
      user = User.create

      entries = [track1.id, track2.id]
      set_redis_with_values('GLOBAL_SHORT_TRACK_SUGGESTION', entries)

      get :short, format: :json, access_token: user.access_token

      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['tracks'].first['id']).to eq track1.id
      expect(result['tracks'].last['id']).to eq track2.id
      expect(result['tracks'].first['comedian']['id']).to eq comedian.id
      expect(result['tracks'].last['comedian']['id']).to eq comedian.id
      clear_redis_with_values('GLOBAL_SHORT_TRACK_SUGGESTION')
    end
  end

  describe 'GET #banner' do
    it 'should succedd and return two images' do
      user = User.create
      comedian1 = Comedian.create(banner_url: '/images/url1.png')
      comedian2 = Comedian.create(banner_url: '/images/url2.jpg')
      key = 'GLOBAL_BANNER_COMEDIAN_IDS'
      set_redis_with_values(key, [comedian1.id, comedian2.id])

      get :banner, format: :json, access_token: user.access_token
      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['comedians'].count).to eq 2
      expect(result['comedians'][0]['banner_url']).to eq '/images/url1.png'
      expect(result['comedians'][1]['banner_url']).to eq '/images/url2.jpg'
      expect(result['comedians'][0]['id']).to eq comedian1.id
      expect(result['comedians'][1]['id']).to eq comedian2.id
      clear_redis_with_values(key)
    end
  end

  describe 'GET #next' do
    it 'should return 1 track' do
      user = User.create
      comedian = Comedian.create
      playlist_key = "next_playlist_for_user-#{user.id}"
      global_key = 'next_playlist_global'
      track1 = Track.create(comedian_id: comedian.id)
      track2 = Track.create(comedian_id: comedian.id)
      track3 = Track.create(comedian_id: comedian.id)
      track4 = Track.create(comedian_id: comedian.id)
      track5 = Track.create(comedian_id: comedian.id)
      $redis.with do |conn|
        conn.del(playlist_key)
        conn.del(global_key)
        conn.set(global_key, "#{track1.id}, #{track2.id}, #{track3.id}, #{track4.id}, #{track5.id}")
      end
      get :next, format: :json, access_token: user.access_token, size: 1
      result = JSON.parse(response.body)
      redis_result = []
      $redis.with do |conn|
        redis_result = conn.get("next_playlist_for_user-#{user.id}").split(',').map(&:to_i)
      end
      expect(redis_result[0]).to eq track2.id
      expect(redis_result[1]).to eq track3.id
      expect(redis_result[2]).to eq track4.id
      expect(redis_result[3]).to eq track5.id
      expect(redis_result[4]).to eq track1.id
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['tracks'].count).to eq 1
      expect(result['tracks'][0]['id']).to eq track1.id
      expect(result['tracks'][0]['comedian']['id']).to eq comedian.id
      expect(result['user']['id']).to eq user.id
    end

    it 'should return 3 tracks' do
      user = User.create
      comedian = Comedian.create
      playlist_key = "next_playlist_for_user-#{user.id}"
      global_key = 'next_playlist_global'
      track1 = Track.create(comedian_id: comedian.id)
      track2 = Track.create(comedian_id: comedian.id)
      track3 = Track.create(comedian_id: comedian.id)
      track4 = Track.create(comedian_id: comedian.id)
      track5 = Track.create(comedian_id: comedian.id)
      $redis.with do |conn|
        conn.del(playlist_key)
        conn.del(global_key)
        conn.set(global_key, "#{track1.id}, #{track2.id}, #{track3.id}, #{track4.id}, #{track5.id}")
      end
      get :next, format: :json, access_token: user.access_token, size: 3
      result = JSON.parse(response.body)
      redis_result = []
      $redis.with do |conn|
        redis_result = conn.get("next_playlist_for_user-#{user.id}").split(',').map(&:to_i)
      end
      expect(redis_result[0]).to eq track4.id
      expect(redis_result[1]).to eq track5.id
      expect(redis_result[2]).to eq track1.id
      expect(redis_result[3]).to eq track2.id
      expect(redis_result[4]).to eq track3.id
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['tracks'].count).to eq 3
      expect(result['tracks'][0]['id']).to eq track1.id
      expect(result['tracks'][1]['id']).to eq track2.id
      expect(result['tracks'][2]['id']).to eq track3.id
      expect(result['tracks'][2]['comedian']['id']).to eq comedian.id
      expect(result['user']['id']).to eq user.id
    end
  end
  #describe 'GET #next' do
  #  it 'should return a hash of tracks' do
  #    $redis.with { |conn| conn.del('global_next_recommendations') }
  #    user = User.create
  #    values =
  #      {
  #        name: 'names', biography: 'biographys', website: 'websites',
  #        twitter_name: 'twitter_names', facebook_name: 'facebook_names',
  #        instagram_name: 'instagram_names', profile_picture: '/profile_pictures'
  #      }
  #    comedian = Comedian.create(values)
#
  #    t1 =
  #      {
  #        title: 'title1',
  #        author: 'author1',
  #        description: 'description1',
  #        duration: 1004,
  #        comedian_id: comedian.id,
  #        high_stream_url: '/stream_url1.mp3',
  #        medium_stream_url: '/stream_url1.mp3',
  #        low_stream_url: '/stream_url1.mp3'
  #      }
#
  #    t2 =
  #      {
  #        title: 'title2',
  #        author: 'author2',
  #        description: 'description2',
  #        duration: 120,
  #        comedian_id: comedian.id,
  #        high_stream_url: '/stream_url2.mp3',
  #        medium_stream_url: '/stream_url2.mp3',
  #        low_stream_url: '/stream_url2.mp3'
  #      }
#
  #    t3 =
  #      {
  #        title: 'title2',
  #        author: 'author2',
  #        description: 'description2',
  #        duration: 121,
  #        comedian_id: comedian.id,
  #        high_stream_url: '/stream_url2.mp3',
  #        medium_stream_url: '/stream_url2.mp3',
  #        low_stream_url: '/stream_url2.mp3'
  #      }
#
  #    old_count = Track.count
  #    track1 = Track.new(t1)
  #    track2 = Track.new(t2)
  #    track3 = Track.new(t3)
#
  #    track1.save!
  #    track2.save!
  #    track3.save!
#
  #    expect(Track.count).to eq (old_count + 3)
#
  #    set_redis_next_recommendations
#
  #    get :next, format: :json, access_token: user.access_token, size: 3
#
  #    result = JSON.parse(response.body)
  #    expect(response.status).to eq 200
  #    expect(result['success']).to eq true
  #    expect(result['tracks']).to_not be nil
  #    expect(result['tracks'].count).to eq 3
  #    r1 = result['tracks'].first
  #    r2 = result['tracks'].second
  #    r3 = result['tracks'].third
  #    expect(r1['id']).to eq track1.id
  #    expect(r2['id']).to eq track2.id
  #    expect(r3['id']).to eq track3.id
  #    expect(r1['high_stream_url']).to eq track1.proper_high_stream_url
  #    expect(r2['high_stream_url']).to eq track2.proper_high_stream_url
  #    expect(r3['high_stream_url']).to eq track3.proper_high_stream_url
  #    expect(r1['medium_stream_url']).to eq track1.proper_medium_stream_url
  #    expect(r2['medium_stream_url']).to eq track2.proper_medium_stream_url
  #    expect(r3['medium_stream_url']).to eq track3.proper_medium_stream_url
  #    expect(r1['low_stream_url']).to eq track1.proper_low_stream_url
  #    expect(r2['low_stream_url']).to eq track2.proper_low_stream_url
  #    expect(r3['low_stream_url']).to eq track3.proper_low_stream_url
  #    expect(r1['comedian']['id']).to eq track1.comedian.id
  #    expect(r2['comedian']['id']).to eq track2.comedian.id
  #    expect(r3['comedian']['id']).to eq track3.comedian.id
  #    expect(r1['comedian']['profile_picture']).to eq track1.comedian.proper_profile_picture
  #    expect(r2['comedian']['profile_picture']).to eq track2.comedian.proper_profile_picture
  #    expect(r3['comedian']['profile_picture']).to eq track3.comedian.proper_profile_picture
  #    $redis.with do |conn|
  #      conn.del('global_next_recommendations')
  #      conn.keys('*next*').each do |key|
  #        conn.del(key)
  #      end
  #    end
#
  #  end
  #end
end
