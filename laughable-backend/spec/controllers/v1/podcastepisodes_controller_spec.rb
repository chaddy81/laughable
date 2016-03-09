require 'database_cleaner'
require 'rails_helper'

RSpec.describe V1::PodcastepisodesController, type: :controller do
  render_views


  describe 'GET #set_progress' do
    it 'should work' do
      user = User.create
      episode1 = Podcastepisode.create
      episode2 = Podcastepisode.create
      get :set_progress, id: episode1.id, duration: 100, access_token: user.access_token
      episode1_duration = $redis.with { |c| c.get("#{user.id}-#{episode1.id}") }
      episode2_duration = $redis.with { |c| c.get("#{user.id}-#{episode2.id}") }
    end
  end
  describe 'POST #custom_update' do
    it 'should deny access' do
      user = User.create
      post :custom_update, id: 0, key: 'key', value: 'value', access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 403
      expect(result['success']).to eq false
      expect(result['errors']['user']).to eq 'does not have permission to do this'
    end

    it 'should successfully queue up a value alteration' do
      user = User.create(admin: true)
      episode = Podcastepisode.create(title: 'old')

      post :custom_update, id: episode.id, key: 'title', value: 'new', access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      res = Podcastepisode.find_by(id: episode.id)
      expect(res.id).to eq episode.id
      expect(res.title).to eq 'old'
      change = Change.where(data_type: 'episode', data_id: episode.id).last
      expect(change.data_type).to eq 'episode'
      expect(change.values['title']).to eq 'new'
    end

    it 'should fail to alter a value because it is not allowed' do
      user = User.create(admin: true)
      episode = Podcastepisode.create(title: 'old')

      post :custom_update, id: episode.id, key: 'user_id', value: user.id, access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 400
      expect(result['success']).to eq false
      res = Podcastepisode.find_by(id: episode.id)
      expect(res.id).to eq episode.id
      expect(res.title).to eq 'old'
      expect(result['errors']['params']).to eq 'are missing or incorrect'
    end
  end

  describe 'GET #info' do
    it 'should return status 200 and success true' do
      get :info, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['success']).to eq true
    end
  end

  describe 'GET #show' do
    it 'should fail because episode does not exist' do
      user = User.create
      get :show, format: :json, id: 0, access_token: user.access_token
      expect(response.status).to eq 400
      result = JSON.parse(response.body)
      expect(result['success']).to eq false
      expect(result['errors']['episode']).to eq 'does not exist'
    end
    it 'should succeed and display the episode' do
      user = User.create
      comedian = Comedian.create
      podcast = Podcast.create({ comedian_ids: [comedian.id] })
      podcastepisode = Podcastepisode.create({ podcast_id: podcast.id })
      get :show, format: :json, id: podcastepisode.id, access_token: user.access_token
      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['episode']['id']).to eq podcastepisode.id
      expect(result['episode']['podcast']['id']).to eq podcast.id
      expect(result['episode']['podcast']['hosts'].first['id']).to eq comedian.id
    end
    it 'should succeed and display new comedian ids array' do
      user = User.create(admin: true)
      comedian = Comedian.create
      comedian1 = Comedian.create
      comedian2 = Comedian.create
      podcast = Podcast.create({ comedian_ids: [comedian.id] })
      episode = Podcastepisode.create({ podcast_id: podcast.id, title: 'oldtitle', duration: 4321 })
      ids = "#{comedian1.id},#{comedian2.id}"
      post :custom_update, id: episode.id, key: 'comedian_ids', value: ids, access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      res = Podcastepisode.find_by(id: episode.id)
      expect(res.id).to eq episode.id
      expect(res.title).to eq 'oldtitle'
      expect(res.comedian_ids).to eq []
      change = Change.where(data_type: 'episode', data_id: episode.id).last
      expect(change.data_type).to eq 'episode'
      expect(change.values['comedian_ids']).to eq ids.split(',').map(&:to_i)

      get :show, format: :json, id: episode.id, access_token: User.create.access_token
      expect(response.status).to eq 200
      res = Podcastepisode.find_by(id: episode.id)
      expect(res.comedian_ids).to eq []
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['episode']['id']).to eq episode.id
      expect(result['episode']['title']).to eq 'oldtitle'
      expect(result['episode']['guests'].count).to eq 2
      expect(result['episode']['guests'][0]['id']).to eq comedian1.id
      expect(result['episode']['guests'][1]['id']).to eq comedian2.id
      expect(result['episode']['podcast']['id']).to eq podcast.id
      expect(result['episode']['podcast']['hosts'].first['id']).to eq comedian.id
    end

    it 'should succeed and display only the most recent altered value' do
      user = User.create(admin: true)
      comedian = Comedian.create
      podcast = Podcast.create({ comedian_ids: [comedian.id] })
      episode = Podcastepisode.create({ podcast_id: podcast.id, title: 'oldtitle', duration: 4321 })

      post :custom_update, id: episode.id, key: 'title', value: 'newtitle', access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      res = Podcastepisode.find_by(id: episode.id)
      expect(res.id).to eq episode.id
      expect(res.title).to eq 'oldtitle'
      change = Change.where(data_type: 'episode', data_id: episode.id).last
      expect(change.data_type).to eq 'episode'
      expect(change.values['title']).to eq 'newtitle'

      post :custom_update, id: episode.id, key: 'duration', value: '1234', access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      res = Podcastepisode.find_by(id: episode.id)
      expect(res.id).to eq episode.id
      expect(res.title).to eq 'oldtitle'
      change = Change.where(data_type: 'episode', data_id: episode.id).last
      expect(change.data_type).to eq 'episode'
      expect(change.values['title']).to eq nil

      get :show, format: :json, id: episode.id, access_token: User.create.access_token
      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['episode']['id']).to eq episode.id
      expect(result['episode']['title']).to eq 'oldtitle'
      expect(result['episode']['duration']).to eq 1234
      expect(result['episode']['podcast']['id']).to eq podcast.id
      expect(result['episode']['podcast']['hosts'].first['id']).to eq comedian.id
    end

    it 'should succeed and display the altered value' do
      user = User.create(admin: true)
      comedian = Comedian.create
      podcast = Podcast.create({ comedian_ids: [comedian.id] })
      episode = Podcastepisode.create({ podcast_id: podcast.id, title: 'oldtitle' })

      post :custom_update, id: episode.id, key: 'title', value: 'newtitle', access_token: user.access_token
      result = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(result['success']).to eq true
      res = Podcastepisode.find_by(id: episode.id)
      expect(res.id).to eq episode.id
      expect(res.title).to eq 'oldtitle'
      change = Change.where(data_type: 'episode', data_id: episode.id).last
      expect(change.data_type).to eq 'episode'
      expect(change.values['title']).to eq 'newtitle'

      get :show, format: :json, id: episode.id, access_token: User.create.access_token
      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['episode']['id']).to eq episode.id
      expect(result['episode']['title']).to eq 'newtitle'
      expect(result['episode']['podcast']['id']).to eq podcast.id
      expect(result['episode']['podcast']['hosts'].first['id']).to eq comedian.id
    end
  end

  describe 'GET #all' do
    it 'should fail because there are no podcast episodes' do
      get :all, format: :json
      expect(response.status).to eq 400
      result = JSON.parse(response.body)
      expect(result['success']).to eq false
      expect(result['errors']['error']).to eq 'there are no podcast episodes'
    end
    it 'should succeed and show 2 episodes' do
      user = User.create
      comedian = Comedian.create
      podcast = Podcast.create({ comedian_ids: [comedian.id] })
      podcastepisode1 = Podcastepisode.create({ podcast_id: podcast.id, publish_date: 1 })
      podcastepisode2 = Podcastepisode.create({ podcast_id: podcast.id, publish_date: 2 })
      get :all, format: :json, access_token: user.access_token
      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['episodes'].second['id']).to eq podcastepisode1.id
      expect(result['episodes'].first['id']).to eq podcastepisode2.id
      expect(result['episodes'].second['podcast']['id']).to eq podcast.id
      expect(result['episodes'].second['podcast']['hosts'].first['id']).to eq comedian.id
      expect(result['episodes'].first['podcast']['id']).to eq podcast.id
      expect(result['episodes'].first['podcast']['hosts'].first['id']).to eq comedian.id
    end
  end
  describe 'GET #multiple' do
    it 'should fail because all ids are missing' do
      get :multiple, format: :json
      expect(response.status).to eq 400
      result = JSON.parse(response.body)
      expect(result['success']).to eq false
      expect(result['errors']['ids']).to eq 'are missing'
    end
    it 'should succeed but return 1 error' do
      user = User.create
      comedian = Comedian.create
      podcast = Podcast.create({ comedian_ids: [comedian.id] })
      podcastepisode1 = Podcastepisode.create({ podcast_id: podcast.id, publish_date: 1 })
      podcastepisode2 = Podcastepisode.create({ podcast_id: podcast.id, publish_date: 2 })
      get :multiple, format: :json, ids: "#{podcastepisode1.id}, 0, #{podcastepisode2.id}", access_token: user.access_token
      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['episodes'].second['id']).to eq podcastepisode1.id
      expect(result['episodes'].first['id']).to eq podcastepisode2.id
      expect(result['episodes'].second['podcast']['id']).to eq podcast.id
      expect(result['episodes'].second['podcast']['hosts'].first['id']).to eq comedian.id
      expect(result['episodes'].first['podcast']['id']).to eq podcast.id
      expect(result['episodes'].first['podcast']['hosts'].first['id']).to eq comedian.id
      expect(result['episodes'].count).to eq 2
      expect(result['errors']['0']).to eq 'does not exist'
    end
    it 'should succeed and return 3 episodes' do
      user = User.create
      comedian = Comedian.create
      podcast = Podcast.create({ comedian_ids: [comedian.id] })
      podcastepisode1 = Podcastepisode.create({ podcast_id: podcast.id, publish_date: 1 })
      podcastepisode2 = Podcastepisode.create({ podcast_id: podcast.id, publish_date: 2 })
      podcastepisode3 = Podcastepisode.create({ podcast_id: podcast.id, publish_date: 333 })
      get :multiple, format: :json, ids: "#{podcastepisode1.id}, #{podcastepisode3.id}, #{podcastepisode2.id}", access_token: user.access_token
      expect(response.status).to eq 200
      result = JSON.parse(response.body)
      expect(result['success']).to eq true
      expect(result['episodes'][0]['id']).to eq podcastepisode3.id
      expect(result['episodes'][1]['id']).to eq podcastepisode2.id
      expect(result['episodes'][2]['id']).to eq podcastepisode1.id

      expect(result['episodes'][0]['podcast']['id']).to eq podcast.id
      expect(result['episodes'][1]['podcast']['id']).to eq podcast.id
      expect(result['episodes'][2]['podcast']['id']).to eq podcast.id

      expect(result['episodes'][0]['podcast']['hosts'].first['id']).to eq comedian.id
      expect(result['episodes'][1]['podcast']['hosts'].first['id']).to eq comedian.id
      expect(result['episodes'][2]['podcast']['hosts'].first['id']).to eq comedian.id

      expect(result['episodes'].count).to eq 3
    end
  end
end
