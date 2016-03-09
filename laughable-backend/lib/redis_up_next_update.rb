class RedisUpNextUpdate
  include Sidekiq::Worker

  def perform(type, id)
    if type == 'add'
      $redis.with do |conn|
        global = 'next_playlist_global'
        keys = conn.keys('next_playlist_for_user-*')
        global_redis = conn.get(global)
        global_track_ids = []
        global_track_ids = global_redis.split(',').map(&:to_i) if global_redis

        global_track_ids << id.to_i
        conn.set(global, global_track_ids.join(','))
        keys.each do |key|
          values = conn.get(key).split(',').map(&:to_i)
          values << id.to_i
          conn.set(key, values.join(','))
        end
      end
    else
      # For when a track gets deleted
      $redis.with do |conn|
        global = 'next_playlist_global'
        keys = conn.keys('next_playlist_for_user-*')
        global_track_ids = conn.get(global).split(',').map(&:to_i)
        global_track_ids.delete(id.to_i)
        conn.set(global, global_track_ids.join(','))
        keys.each do |key|
          values = conn.get(key).split(',').map(&:to_i)
          values.delete(id.to_i)
          conn.set(key, values.join(','))
        end
      end
    end
  end
end
