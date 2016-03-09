# Takes all of the changes from the Change model and executes them on actual data.

class ChangeTask
  include Sidekiq::Worker

  def perform
    all_podcasts.each do |entry|
      podcast = entry.first
      entry.last.each do |change|
        podcast.update(change.values) unless change.nil?
      end
    end

    all_episodes.each do |entry|
      episode = entry.first
      entry.last.each do |change|
        episode.update(change.values) unless change.nil?
      end
    end

    all_tracks.each do |entry|
      track = entry.first
      entry.last.each do |change|
        track.update(change.values) unless change.nil?
      end
    end

    all_comedians.each do |entry|
      comedian = entry.first
      entry.last.each do |change|
        comedian.update(change.values) unless change.nil?
      end
    end
  end

  def all_podcasts
    result = Podcast.all.map do |p|
      [p, Change.where(data_type: 'podcast', data_id: p.id).order(:id)]
    end
    result
  end

  def all_episodes
    result = Podcastepisode.all.map do |p|
      [p, Change.where(data_type: 'episode', data_id: p.id).order(:id)]
    end
    result
  end

  def all_tracks
    result = Track.all.map do |p|
      [p, Change.where(data_type: 'track', data_id: p.id).order(:id)]
    end
    result
  end

  def all_comedians
    result = Comedian.all.map do |p|
      [p, Change.where(data_type: 'comedian', data_id: p.id).order(:id)]
    end
    result
  end
end
