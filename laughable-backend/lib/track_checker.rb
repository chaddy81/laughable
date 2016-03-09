class TrackChecker
  include Sidekiq::Worker
  def perform(track_id)
    track = Track.find_by(id: track_id)
    if track.present?
      track_check(track)
    else
      track_missing(track.id)
    end
  end

  private

  def track_check(track)
    url_base = ENV['MEDIA_FILE_URL'].split("://")[1]
    high_track_stream = track.high_stream_url
    medium_track_stream = track.medium_stream_url
    low_track_stream = track.low_stream_url
    if high_track_stream.nil?
      high_track_missing(track.id)
    else
      high_track_request(url_base, high_track_stream, track.id)
    end

    if medium_track_stream.nil?
      medium_track_missing(track.id)
    else
      medium_track_request(url_base, medium_track_stream, track.id)
    end

    if low_track_stream.nil?
      low_track_missing(track.id)
    else
      low_track_request(url_base, low_track_stream, track.id)
    end
  end

  def low_track_request(url_base, track_stream, track_id)
    require 'net/http'
    begin
      Net::HTTP.start(url_base, 80) do |http|
        unless http.head(track_stream).class == Net::HTTPOK
          $redis.with do |conn|
            conn.sadd('track_stream_low_invalid', track_id)
          end
        end
      end
    rescue SocketError => e
      $redis.with do |conn|
        conn.sadd('track_stream_low_invalid')
      end
    end
  end

  def medium_track_request(url_base, track_stream, track_id)
    require 'net/http'
    begin
      Net::HTTP.start(url_base, 80) do |http|
        unless http.head(track_stream).class == Net::HTTPOK
          $redis.with do |conn|
            conn.sadd('track_stream_medium_invalid', track_id)
          end
        end
      end
    rescue SocketError => e
      $redis.with do |conn|
        conn.sadd('track_stream_medium_invalid')
      end
    end
  end

  def high_track_request(url_base, track_stream, track_id)
    require 'net/http'
    begin
      Net::HTTP.start(url_base, 80) do |http|
        unless http.head(track_stream).class == Net::HTTPOK
          $redis.with do |conn|
            conn.sadd('track_stream_high_invalid', track_id)
          end
        end
      end
    rescue SocketError => e
      $redis.with do |conn|
        conn.sadd('track_stream_high_invalid')
      end
    end
  end

  def high_track_missing(track_id)
    $redis.with do |conn|
      conn.sadd('track_stream_high_missing', track_id)
    end
  end

  def medium_track_missing(track_id)
    $redis.with do |conn|
      conn.sadd('track_stream_medium_missing', track_id)
    end
  end

  def low_track_missing(track_id)
    $redis.with do |conn|
      conn.sadd('track_stream_low_missing', track_id)
    end
  end
end
