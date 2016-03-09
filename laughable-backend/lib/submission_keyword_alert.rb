class SubmissionKeywordAlert
  include Sidekiq::Worker

  def perform(input_hash)
    message = {}
    message[:code] = input_hash['code']
    message[:success] = input_hash['success'] # The string 'successful' or 'unsuccessful'
    message[:ip] = input_hash['ip']
    send_message(message)
  end

  private

  def send_message(message)
    connection_info = hubot_information
    u = "http://#{connection_info[:host]}:#{connection_info[:port]}/hubot/codeword"
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
