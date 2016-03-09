class ProfileChecker
  include Sidekiq::Worker
  def perform(comedian_id)
    comedian = Comedian.find_by(id: comedian_id)
    if comedian.present?
      profile_check(comedian)
    else
      profile_missing(comedian_id)
    end
  end

  private

  def profile_check(comedian)
    url_base = ENV['MEDIA_FILE_URL'].split("://")[1]
    profile_picture = comedian.profile_picture
    puts "Comedian id is #{comedian.id}, the base url is #{url_base} and the profile picture is #{profile_picture}"
    if profile_picture.nil?
      profile_missing(comedian.id)
    else
      comedian_request(url_base, profile_picture, comedian.id)
    end
  end

  def comedian_request(url_base, profile_picture, comedian_id)
    require 'net/http'
    begin
      Net::HTTP.start(url_base, 80) do |http|
        unless http.head(profile_picture).class == Net::HTTPOK
          $redis.with do |conn|
            conn.sadd('profile_picture_invalid', comedian_id)
          end
        end
      end
    rescue SocketError => e
      $redis.with do |conn|
        conn.sadd('profile_picture_invalid', comedian_id)
      end
    end
  end

  def profile_missing(comedian_id)
    $redis.with do |conn|
      conn.sadd('profile_picture_missing', comedian_id)
    end
  end
end
