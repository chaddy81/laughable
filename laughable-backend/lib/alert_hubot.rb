class AlertHubot
  include Sidekiq::Worker

  def perform
    message = {}
    track_info = track_information
    picture_info = profile_information
    message[:missing_high_tracks] = track_info[:missing_high] if track_info[:missing_high].present?
    message[:invalid_high_tracks] = track_info[:invalid_high] if track_info[:invalid_high].present?
    message[:missing_medium_tracks] = track_info[:missing_medium] if track_info[:missing_medium].present?
    message[:invalid_medium_tracks] = track_info[:invalid_medium] if track_info[:invalid_medium].present?
    message[:missing_low_tracks] = track_info[:missing_low] if track_info[:missing_low].present?
    message[:invalid_low_tracks] = track_info[:invalid_low] if track_info[:invalid_low].present?
    message[:missing_pictures] = picture_info[:missing] if picture_info[:missing].present?
    message[:invalid_pictures] = picture_info[:invalid] if picture_info[:invalid].present?
    clear_redis
    send_message(message)
  end

  private

  def send_message(message)
    connection_info = hubot_information
    puts "Connection info: #{connection_info}"
    u = "http://#{connection_info[:host]}:#{connection_info[:port]}/hubot/alert"
    uri = URI.parse(u)
    begin
      http = Net::HTTP.new(connection_info[:host], connection_info[:port])
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(message)
      http.request(request)
    rescue Net::ReadTimeout => e
      puts e
    end
  end

  def track_information
    result = {}
    $redis.with do |conn|
      result[:missing_high] = conn.smembers('track_stream_high_missing').uniq.join(', ')
      result[:invalid_high] = conn.smembers('track_stream_high_invalid').uniq.join(', ')
      result[:missing_medium] = conn.smembers('track_stream_medium_missing').uniq.join(', ')
      result[:invalid_medium] = conn.smembers('track_stream_medium_invalid').uniq.join(', ')
      result[:missing_low] = conn.smembers('track_stream_low_missing').uniq.join(', ')
      result[:invalid_low] = conn.smembers('track_stream_low_invalid').uniq.join(', ')
    end
    result
  end

  def profile_information
    result = {}
    $redis.with do |conn|
      result[:missing] = conn.smembers('profile_picture_missing').uniq.join(', ')
      result[:invalid] = conn.smembers('profile_picture_invalid').uniq.join(', ')
    end
    result
  end

  def hubot_information
    result = {}
    $redis.with do |conn|
      host = conn.get('hubot-information-host')
      port = conn.get('hubot-information-port')
      result[:host] = host || 'localhost'
      result[:port] = port || 8080
    end
    result
  end

  def clear_redis
    require 'net/http'
    $redis.with do |conn|
      conn.del('track_stream_high_missing')
      conn.del('track_stream_high_invalid')
      conn.del('track_stream_medium_missing')
      conn.del('track_stream_medium_invalid')
      conn.del('track_stream_low_missing')
      conn.del('track_stream_low_invalid')
      conn.del('profile_picture_missing')
      conn.del('profile_picture_invalid')
    end
  end
end
