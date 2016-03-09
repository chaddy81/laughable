require 'rails_helper'
require 'spec_helper'
require 'change_task'

RSpec.describe ChangeTask do
  describe 'when altering podcasts' do
    it 'should change the title' do
      podcast = Podcast.create(title: 'old')
      expect(podcast.title).to eq 'old'
      Change.create(data_type: 'podcast', data_id: podcast.id, values: { title: 'new' })
      ChangeTask.perform_async
      podcast = Podcast.find_by(id: podcast.id)
      expect(podcast.title).to eq 'new'
    end
    it 'should change the comedians' do
      comedian1 = Comedian.create
      comedian2 = Comedian.create
      comedian3 = Comedian.create
      comedian4 = Comedian.create
      podcast = Podcast.create(title: 'title', comedian_ids: [comedian1.id, comedian2.id])
      expect(podcast.comedian_ids).to eq [comedian1.id, comedian2.id]
      Change.create(data_type: 'podcast', data_id: podcast.id, values: { comedian_ids: [comedian3.id, comedian4.id]})
      ChangeTask.perform_async
      podcast = Podcast.find_by(id: podcast.id)
      expect(podcast.comedian_ids).to eq [comedian3.id, comedian4.id]
    end
  end
  describe 'when altering episodes' do
    it 'should change the title' do
      comedian = Comedian.create
      podcast = Podcast.create(comedian_ids: [comedian.id])
      episode = Podcastepisode.create(podcast_id: podcast.id, title: 'old')
      expect(episode.podcast_id).to eq podcast.id
      Change.create(data_type: 'episode', data_id: episode.id, values: { title: 'new' })
      ChangeTask.perform_async
      episode = Podcastepisode.find_by(id: episode.id)
      expect(episode.title).to eq 'new'
    end
    it 'should change what comedians are guests and the title' do
      comedian1 = Comedian.create
      comedian2 = Comedian.create
      comedian3 = Comedian.create
      comedian4 = Comedian.create
      podcast = Podcast.create(comedian_ids: [comedian1.id])
      episode = Podcastepisode.create(podcast_id: podcast.id, title: 'old', comedian_ids: [comedian1.id, comedian2.id])
      expect(episode.podcast_id).to eq podcast.id
      expect(episode.comedian_ids).to eq [comedian1.id, comedian2.id]
      Change.create(data_type: 'episode', data_id: episode.id, values: { title: 'new', comedian_ids: [comedian3.id, comedian4.id] })
      ChangeTask.perform_async
      episode = Podcastepisode.find_by(id: episode.id)
      expect(episode.title).to eq 'new'
      expect(episode.comedian_ids).to eq [comedian3.id, comedian4.id]
    end
  end
  describe 'when altering tracks' do
    it 'should change the title' do
      comedian = Comedian.create
      track = Track.create(comedian_id: comedian.id, title: 'old')
      Change.create(data_type: 'track', data_id: track.id, values: { title: 'new' })
      ChangeTask.perform_async
      track.reload
      expect(track.comedian_id).to eq comedian.id
      expect(track.title).to eq 'new'
    end
    it 'should change the title and change the comedian it belongs to' do
      comedian1 = Comedian.create
      comedian2 = Comedian.create
      track = Track.create(comedian_id: comedian1.id, title: 'old')
      Change.create(data_type: 'track', data_id: track.id, values: { title: 'new', comedian_id: comedian2.id })
      ChangeTask.perform_async
      track.reload
      expect(track.comedian_id).to eq comedian2.id
      expect(track.title).to eq 'new'
    end
  end
  describe 'when changing comedian information' do
    it 'should change the first and last name' do
      comedian = Comedian.create(first_name: 'fold', last_name: 'lold')
      Change.create(data_type: 'comedian', data_id: comedian.id, values: { first_name: 'fnew', last_name: 'lnew' })
      ChangeTask.perform_async
      comedian.reload
      expect(comedian.first_name).to eq 'fnew'
      expect(comedian.last_name).to eq 'lnew'
    end
  end
end
