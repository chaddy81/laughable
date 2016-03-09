require 'rails_helper'

RSpec.describe Podcast, type: :model do
  describe 'when displaying a podcast episode' do
    it 'should have the basic information present' do
      podcast = Podcast.create(title: 'title', summary: 'summary', image_url: 'image_url')

      result = podcast.display_helper

      expect(result[:id]).to eq podcast.id
      expect(result[:title]).to eq podcast.title
      expect(result[:summary]).to eq podcast.summary
      expect(result[:profile_picture]).to eq [podcast.image_url]
      expect(result[:has_guests]).to eq false
      expect(result[:has_featured_episodes]).to eq false
    end
    it 'should have the basic information and guests present' do
      podcast = Podcast.create(title: 'title', summary: 'summary', image_url: 'image_url')
      comedian = Comedian.create
      Podcastepisode.create(podcast_id: podcast.id, comedian_ids: [comedian.id])

      result = podcast.display_helper
      expect(result[:id]).to eq podcast.id
      expect(result[:title]).to eq podcast.title
      expect(result[:summary]).to eq podcast.summary
      expect(result[:profile_picture]).to eq [podcast.image_url]
      expect(result[:has_guests]).to eq true
      expect(result[:has_featured_episodes]).to eq false
    end

    it 'should have the basic information and featured episodes present' do
      $redis.with do |c|
        keys = c.keys('*GLOBAL_FEATURED_EPISODES*')
        keys.each { |k| c.del(k) }
      end
      podcast = Podcast.create(title: 'title', summary: 'summary', image_url: 'image_url')
      episode = Podcastepisode.create(podcast_id: podcast.id)

      $redis.with do |c|
        c.set("GLOBAL_FEATURED_EPISODES-#{podcast.id}", "#{episode.id}")
      end

      result = podcast.display_helper
      expect(result[:id]).to eq podcast.id
      expect(result[:title]).to eq podcast.title
      expect(result[:summary]).to eq podcast.summary
      expect(result[:profile_picture]).to eq [podcast.image_url]
      expect(result[:has_guests]).to eq false
      expect(result[:has_featured_episodes]).to eq true
    end
  end
end
