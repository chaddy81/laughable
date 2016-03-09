require 'database_cleaner'
require 'rails_helper'

RSpec.describe V1::PodcastsController, type: :controller do
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

  describe 'GET #alter_episodes' do
    it 'should deny access' do
      user = User.create
      get :alter_episodes, id: 0, access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 403
      expect(result['success']).to eq false
      expect(result['errors']['user']).to eq 'does not have permission to do this'
    end
    it 'should fail and say that ids are not specified' do
      clear_multiple_keys('GLOBAL_FEATURED_EPISODES')
      user = User.create(admin: true)

      get :alter_episodes, id: 0, access_token: user.access_token, ids: nil
      result = JSON.parse(response.body)
      expect(response.status).to eq 400
      expect(result['success']).to eq false
      expect(result['errors']['ids']).to eq 'not specified'
    end

    it 'should fail and say that two episodes are not part of the podcast' do
      clear_multiple_keys('GLOBAL_FEATURED_EPISODES')
      user = User.create(admin: true)

      podcast1 = Podcast.create
      podcast2 = Podcast.create
      ep1 = Podcastepisode.create(podcast_id: podcast1.id)
      ep2 = Podcastepisode.create(podcast_id: podcast2.id)
      ep3 = Podcastepisode.create(podcast_id: podcast1.id)

      key1 = "GLOBAL_FEATURED_EPISODES-#{podcast1.id}"
      key2 = "GLOBAL_FEATURED_EPISODES-#{podcast2.id}"
      value1 = "#{ep1.id},#{ep3.id}"
      value2 = "#{ep2.id}"

      get :alter_episodes, id: podcast2.id, access_token: user.access_token, ids: value1
      result = JSON.parse(response.body)
      expect(response.status).to eq 400
      expect(result['success']).to eq false
      expect(result['errors'][ep1.id.to_s]).to eq 'is not part of this podcast'
      expect(result['errors'][ep3.id.to_s]).to eq 'is not part of this podcast'

      expect(get_redis(key1)).to eq nil
      expect(get_redis(key2)).to eq nil
    end

    it 'should work and successfully alter the list' do
      clear_multiple_keys('GLOBAL_FEATURED_EPISODES')
      user = User.create(admin: true)
      podcast1 = Podcast.create
      podcast2 = Podcast.create
      ep1 = Podcastepisode.create(podcast_id: podcast1.id)
      ep2 = Podcastepisode.create(podcast_id: podcast2.id)
      ep3 = Podcastepisode.create(podcast_id: podcast1.id)
      key1 = "GLOBAL_FEATURED_EPISODES-#{podcast1.id}"
      key2 = "GLOBAL_FEATURED_EPISODES-#{podcast2.id}"
      value1 = "#{ep1.id},#{ep3.id}"
      value2 = "#{ep2.id}"

      set_redis(key1, value2)

      get :alter_episodes, id: podcast1.id, access_token: user.access_token, ids: value1
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['episodes'].count).to eq 2
      expect(result['episodes'][0]['id']).to eq ep1.id
      expect(result['episodes'][1]['id']).to eq ep3.id
      expect(get_redis(key1)).to_not eq value2
      expect(get_redis(key1)).to eq value1
      expect(get_redis(key2)).to eq nil
    end
  end

  describe 'GET #featured_episodes' do
    it 'should deny access' do
      get :featured_episodes, id: 0, access_token: '1234asdf'
      result = JSON.parse(response.body)
      expect(response.status).to eq 403
      expect(result['success']).to eq false
      expect(result['errors']['access_token']).to eq 'is invalid'
    end

    it 'should return an empty result' do
      user = User.create
      podcast = Podcast.create
      key = "GLOBAL_FEATURED_EPISODES-#{podcast.id}"
      clear_redis(key)

      get :featured_episodes, id: podcast.id, access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['episodes'].count).to eq 0
    end

    it 'should return 2 episodes' do
      user = User.create
      podcast1 = Podcast.create
      podcast2 = Podcast.create
      ep1 = Podcastepisode.create(podcast_id: podcast1.id)
      ep2 = Podcastepisode.create(podcast_id: podcast2.id)
      ep3 = Podcastepisode.create(podcast_id: podcast1.id)

      key1 = "GLOBAL_FEATURED_EPISODES-#{podcast1.id}"
      key2 = "GLOBAL_FEATURED_EPISODES-#{podcast2.id}"

      value1 = "#{ep1.id},#{ep3.id}"
      value2 = "#{ep2.id}"

      clear_multiple_keys('GLOBAL_FEATURED_EPISODES')
      set_redis(key1, value1)
      set_redis(key2, value2)

      get :featured_episodes, id: podcast1.id, access_token: user.access_token

      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['episodes'].count).to eq 2
      expect(result['episodes'][0]['id']).to eq ep1.id
      expect(result['episodes'][1]['id']).to eq ep3.id
    end
  end

  describe 'GET #alter_only_show_featured_episodes' do
    it 'should deny access' do
      user = User.create
      get :alter_only_show_featured_episodes, id: 0, type: 'remove', access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 403
      expect(result['success']).to eq false
      expect(result['errors']['user']).to eq 'does not have permission to do this'
    end
    it 'should error because type is not specified' do
      user = User.create(admin: true)
      get :alter_only_show_featured_episodes, id: 0, type: nil, access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 400
      expect(result['success']).to eq false
      expect(result['errors']['parameters']).to eq 'need to be specified'
    end
    it 'should error because id is not specified' do
      user = User.create(admin: true)
      get :alter_only_show_featured_episodes, id: 0, type: 'remove', access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 400
      expect(result['success']).to eq false
      expect(result['errors']['parameters']).to eq 'need to be specified'
    end
    it 'should successfully add a podcast' do
      user = User.create(admin: true)
      podcast1 = Podcast.create
      podcast2 = Podcast.create
      key = "GLOBAL_SHOW_FEATURED_ONLY_EPISODES"
      clear_redis(key)
      get :alter_only_show_featured_episodes, id: podcast1.id, type: 'add', access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['errors'].present?).to eq false
      expect(result['podcast']).to eq "with ID #{podcast1.id} successfully added"

      get :all, access_token: User.create.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['podcasts'].count).to eq 2
      expect(result['podcasts'][0]['id']).to eq podcast1.id
      expect(result['podcasts'][1]['id']).to eq podcast2.id
      expect(result['podcasts'][0]['only_show_featured_episodes']).to eq true
      expect(result['podcasts'][1]['only_show_featured_episodes']).to eq false
      ids = get_redis(key).split(',').map(&:to_i)
      expect(ids.count).to eq 1
      expect(ids[0]).to eq podcast1.id
    end
    it 'should successfully remove a podcast' do
      user = User.create(admin: true)
      podcast1 = Podcast.create
      podcast2 = Podcast.create
      key = "GLOBAL_SHOW_FEATURED_ONLY_EPISODES"
      clear_redis(key)
      set_redis(key, "podcast1.id")
      get :alter_only_show_featured_episodes, id: podcast1.id, type: 'remove', access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['errors'].present?).to eq false
      expect(result['podcast']).to eq "with ID #{podcast1.id} successfully removed"

      get :all, access_token: User.create.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(result['podcasts'].count).to eq 2
      expect(result['podcasts'][0]['id']).to eq podcast1.id
      expect(result['podcasts'][1]['id']).to eq podcast2.id
      expect(result['podcasts'][0]['only_show_featured_episodes']).to eq false
      expect(result['podcasts'][1]['only_show_featured_episodes']).to eq false
      ids = []
      ids = get_redis(key).split(',').map(&:to_i) if get_redis(key).present?
      expect(ids.count).to eq 0
    end
  end

  describe 'GET #custom_update' do
    it 'should deny access' do
      user = User.create
      post :custom_update, id: 0, key: 'key', value: 'value', access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 403
      expect(result['success']).to eq false
      expect(result['errors']['user']).to eq 'does not have permission to do this'
    end
    it 'should successfully \'queue up\' a value to be changed' do
      user = User.create(admin: true)
      podcast = Podcast.create(title: 'old')
      change_count = Change.count
      post :custom_update, id: podcast.id, key: 'title', value: 'new', access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(Podcast.find(podcast.id).title).to eq 'old'
      change = Change.where(data_type: 'podcast', data_id: podcast.id).last
      expect(Change.count).to eq change_count + 1
      expect(change.data_type).to eq 'podcast'
      expect(change.values['title']).to eq 'new'
    end

    it 'should fail when altering an unallowed value' do
      user = User.create(admin: true)
      podcast = Podcast.create(title: 'old')
      post :custom_update, id: podcast.id, key: 'name', value: 'new', access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 400
      expect(result['success']).to eq false
      expect(result['errors']['params']).to eq 'are missing or incorrect'
    end
  end

  describe 'GET #info' do
    it 'should return status 200 and success true' do
      get :info, format: :json, access_token: User.create.access_token
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['success']).to eq true
    end
  end

  describe 'GET #show' do
    it 'should succeed and display a podcast' do
      comedian1 = Comedian.create
      comedian2 = Comedian.create
      podcast = Podcast.create(comedian_ids: [comedian1.id, comedian2.id])

      get :show, format: :json, id: podcast.id, access_token: User.create.access_token
      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['podcast']['id']).to eq podcast.id
      expect(result['podcast']['hosts'][0]['id']).to eq comedian1.id
      expect(result['podcast']['hosts'][1]['id']).to eq comedian2.id
    end

    it 'should display the queued up changes when returning a podcast' do
      comedian1 = Comedian.create
      comedian2 = Comedian.create
      user = User.create(admin: true)
      podcast = Podcast.create(title: 'old', comedian_ids: [comedian1.id, comedian2.id])
      change_count = Change.count
      post :custom_update, id: podcast.id, key: 'title', value: 'new', access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(Podcast.find(podcast.id).title).to eq 'old'
      expect(Change.count).to eq change_count + 1
      change = Change.where(data_type: 'podcast', data_id: podcast.id).last
      expect(change.data_type).to eq 'podcast'
      expect(change.values['title']).to eq 'new'
      get :show, format: :json, id: podcast.id, access_token: User.create.access_token
      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['podcast']['id']).to eq podcast.id
      expect(result['podcast']['hosts'][0]['id']).to eq comedian1.id
      expect(result['podcast']['hosts'][1]['id']).to eq comedian2.id
      expect(result['podcast']['title']).to eq 'new'
    end
    it 'should display the last change only when returning a podcast' do
      comedian1 = Comedian.create
      comedian2 = Comedian.create
      user = User.create(admin: true)
      podcast = Podcast.create(title: 'old', comedian_ids: [comedian1.id, comedian2.id])
      change_count = Change.count
      post :custom_update, id: podcast.id, key: 'title', value: 'new', access_token: user.access_token
      change = Change.where(data_type: 'podcast', data_id: podcast.id).last
      expect(change.data_type).to eq 'podcast'
      expect(change.values['title']).to eq 'new'
      post :custom_update, id: podcast.id, key: 'summary', value: 'summarynew', access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      expect(Podcast.find(podcast.id).title).to eq 'old'
      expect(Change.count).to eq change_count + 2
      change = Change.where(data_type: 'podcast', data_id: podcast.id).last
      expect(change.data_type).to eq 'podcast'
      expect(change.values['title']).to eq nil
      get :show, format: :json, id: podcast.id, access_token: User.create.access_token
      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['podcast']['id']).to eq podcast.id
      expect(result['podcast']['hosts'][0]['id']).to eq comedian1.id
      expect(result['podcast']['hosts'][1]['id']).to eq comedian2.id
      expect(result['podcast']['title']).to eq 'old'
      expect(result['podcast']['summary']).to eq 'summarynew'
    end
  end

  describe 'GET #guests' do
    it 'should fail because podcast does not exist' do
      get :guests, format: :json, id: 0, access_token: User.create.access_token
      expect(response.status).to eq 400
      result = JSON.parse(response.body)
      expect(result['success']).to eq false
      expect(result['errors']['podcast']).to eq 'does not exist'
    end
    it 'should succeed' do
      comedian1 = Comedian.create
      comedian2 = Comedian.create
      podcast = Podcast.create
      Podcastepisode.create(comedian_ids: [comedian1.id, comedian2.id], podcast_id: podcast.id)
      Podcastepisode.create(comedian_ids: [comedian1.id, comedian2.id], podcast_id: podcast.id)

      get :guests, format: :json, id: podcast.id, access_token: User.create.access_token
      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['guests'][0]['id']).to eq comedian1.id
      expect(result['guests'][1]['id']).to eq comedian2.id
    end
  end
end
