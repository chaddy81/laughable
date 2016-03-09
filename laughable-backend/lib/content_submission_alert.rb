class ContentSubmissionAlert
  include Sidekiq::Worker

  def perform(input_hash)
    message = {}
    aws_bucket = $s3.bucket('laughable-purgatory')

    track_path = "uploads/#{input_hash['track_name']}"
    photo_path = "uploads/#{input_hash['photo_name']}"

    track = aws_bucket.object(track_path)
    photo = aws_bucket.object(photo_path)

    message[:comedian_name] = input_hash['first_name']
    message[:comedian_surname] = input_hash['last_name']
    message[:track_name] = input_hash['track_name']
    message[:do_not_clip] = input_hash['do_not_clip']
    message[:start] = input_hash['clip_start']
    message[:end] = input_hash['clip_end']
    message[:cms_id] = input_hash['cms_id']
    message[:photo_url] = photo.public_url unless photo.public_url == "https://laughable-purgatory.s3.amazonaws.com/uploads/"
    message[:track_url] = track.public_url unless track.nil?
    puts "\n debug content message: #{message}"
    send_message(message)
  end

  def send_message(message)
    connection_info = hubot_information
    u = "http://#{connection_info[:host]}:#{connection_info[:port]}/hubot/submission"
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
end
