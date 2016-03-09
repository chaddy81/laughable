def redis_setup
  if Rails.env == 'production' || Rails.env == 'staging'
    # Using .env specific environments
    redis_host = ENV['PRODUCTION_REDIS_HOST']
    redis_port = ENV['PRODUCTION_REDIS_PORT']
    #redis_password = ENV['PRODUCTION_REDIS_PASSWORD']
    redis_db = ENV['PRODUCTION_REDIS_DB']

    if redis_host.nil? || redis_port.nil? || redis_db.nil?
      puts 'WARNING: Redis environments not properly set, exiting'
      exit
    end

    if Rails.env == 'production'
      Sidekiq.configure_server do |config|
        url = "redis://#{redis_host}:#{redis_port}/1"
        config.redis = { url: url }
      end

      Sidekiq.configure_client do |config|
        url = "redis://#{redis_host}:#{redis_port}/1"
        config.redis = { url: url }
      end
    elsif Rails.env == 'staging'
      Sidekiq.configure_server do |config|
        url = "redis://#{redis_host}:#{redis_port}/2"
        config.redis = { url: url }
      end

      Sidekiq.configure_client do |config|
        url = "redis://#{redis_host}:#{redis_port}/2"
        config.redis = { url: url }
      end
    end

    ConnectionPool.new(size: 5, timeout: 5) { Redis.new(host: redis_host, port: redis_port, db: redis_db) }

  elsif Rails.env == 'development' || Rails.env == 'test'
    # Using local redis connection
    redis_host = ENV['DEVELOPMENT_REDIS_HOST'] || 'localhost'
    redis_port = ENV['DEVELOPMENT_REDIS_PORT'] || 6379
    redis_db = ENV['DEVELOPMENT_REDIS_DB'] || 0

    Sidekiq.configure_server do |config|
      url = "redis://#{redis_host}:#{redis_port}/1"
      config.redis = { url: url }
    end

    Sidekiq.configure_client do |config|
      url = "redis://#{redis_host}:#{redis_port}/1"
      config.redis = { url: url }
    end

    ConnectionPool.new(size: 5, timeout: 5) { Redis.new(host: redis_host, port: redis_port, db: redis_db) }
  elsif Rails.env == 'staging'
    redis_host = ENV['STAGING_REDIS_HOST'] || 'localhost'
    redis_port = ENV['STAGING_REDIS_PORT'] || 6379
    redis_db = ENV['STAGING_REDIS_DB'] || 0

    Sidekiq.configure_server do |config|
      url = "redis://#{redis_host}:#{redis_port}/1"
      config.redis = { url: url }
    end

    Sidekiq.configure_client do |config|
      url = "redis://#{redis_host}:#{redis_port}/1"
      config.redis = { url: url }
    end

    ConnectionPool.new(size: 5, timeout: 5) { Redis.new(host: redis_host, port: redis_port, db: redis_db) }
  else
    puts "\n Trying out local redis connection"
    redis_host = 'localhost'
    redis_port = '6379'
    redis_db = 0

    Sidekiq.configure_server do |config|
      url = "redis://#{redis_host}:#{redis_port}/1"
      config.redis = { url: url }
    end

    Sidekiq.configure_client do |config|
      url = "redis://#{redis_host}:#{redis_port}/1"
      config.redis = { url: url }
    end
    ConnectionPool.new(size: 5, timeout: 5) { Redis.new(host: redis_host, port: redis_port, db: redis_db) }
  end
end

$redis ||= redis_setup
