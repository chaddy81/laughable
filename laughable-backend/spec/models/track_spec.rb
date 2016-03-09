require 'rails_helper'

RSpec.describe Track, type: :model do
  describe 'create and destroy methods' do
    it 'should add the IDs of newly created tracks to redis and also remove them when destroyed' do
      $redis.with { |conn| conn.del('next_playlist_global') }

      track1 = Track.create
      track1_result = []
      $redis.with do |conn|
        track1_result = conn.get('next_playlist_global').split(',').map(&:to_i)
      end
      expect(track1_result.count).to eq 1
      expect(track1_result[0]).to eq track1.id
      track2 = Track.create
      track2_result = []
      $redis.with do |conn|
        track2_result = conn.get('next_playlist_global').split(',').map(&:to_i)
      end
      expect(track2_result.count).to eq 2
      expect(track2_result[0]).to eq track1.id
      expect(track2_result[1]).to eq track2.id

      # Now track deletion

      track1.destroy
      track1_destroy_result = []
      $redis.with do |conn|
        track1_destroy_result = conn.get('next_playlist_global').split(',').map(&:to_i)
      end
      expect(track1_destroy_result.count).to eq 1
      expect(track1_destroy_result[0]).to eq track2.id
      track2.destroy
      track2_destroy_result = []
      $redis.with do |conn|
        track2_destroy_result = conn.get('next_playlist_global').split(',').map(&:to_i)
      end
      expect(track2_destroy_result.count).to eq 0
      expect(track1_destroy_result.class).to eq Array
    end
  end

  describe 'display helper' do
    it 'returns a hash of attributes' do
      track = Track.new
      track.save!
      result = track.display_helper
      expect(result[:id]).to eq track.id
      expect(result[:author]).to eq track.author
      expect(result[:description]).to eq track.description
      expect(result[:duration]).to eq track.duration
      expect(result[:comedian_id]).to eq track.comedian_id
      expect(result[:high_stream_url]).to eq track.proper_high_stream_url
      expect(result[:medium_stream_url]).to eq track.proper_medium_stream_url
      expect(result[:low_stream_url]).to eq track.proper_low_stream_url
    end
  end

  describe 'comedian' do
    it 'does not have a comedian object' do
      track_values =
        {
          title: 'title1',
          author: 'author1',
          description: 'description1',
          duration: 100,
          comedian_id: nil,
          high_stream_url: '/stream_url1.mp3',
          medium_stream_url: '/stream_url1.mp3',
          low_stream_url: '/stream_url1.mp3'
        }
      track = Track.new(track_values)
      track.save!

      expect(track.comedian).to eq nil
    end
    it 'returns the comedian object of the current track' do
      comedian_values =
        {
          first_name: 'names', biography: 'biographys', website: 'websites',
          twitter_name: 'twitter_names', facebook_name: 'facebook_names',
          instagram_name: 'instagram_names', profile_picture: '/profile_pictures'
        }
      comedian = Comedian.new(comedian_values)
      comedian.save!

      track_values =
        {
          title: 'title1',
          author: 'author1',
          description: 'description1',
          duration: 100,
          comedian_id: comedian.id,
          high_stream_url: '/stream_url1.mp3',
          medium_stream_url: '/stream_url1.mp3',
          low_stream_url: '/stream_url1.mp3'
        }
      track = Track.new(track_values)
      track.save!

      expect(track.comedian).to eq comedian
    end
  end
end
