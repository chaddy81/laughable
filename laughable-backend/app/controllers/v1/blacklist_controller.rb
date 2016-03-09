class V1::BlacklistController < V1::BaseController
  BLACKLISTED_KEY = 'blacklisted-tracks-ids'

  before_action :restrict_only_to_admins

  def info
    render status: 200, json: { success: true }
  end

  def unblacklist
    result = {}
    status = 200

    track_id = params[:id].to_i
    if Track.find_by(id: track_id).nil?
      result[:errors] = { id: 'is invalid' }
      result[:success] = false
      status = 400
    else
      $redis.with do |conn|
        blacklisted_ids = []
        redis_list = conn.get(BLACKLISTED_KEY)
        blacklisted_ids = redis_list.split(',').map(&:to_i) if redis_list
        blacklisted_ids.delete(track_id)
        conn.del(BLACKLISTED_KEY)
        conn.set(BLACKLISTED_KEY, blacklisted_ids.join(','))
        ## Re-add the track to all of the redis objects
        keys = conn.keys('next_playlist*')
        keys.each do |key|
          values = conn.get(key).split(',').map(&:to_i)
          values << track_id
          conn.set(key, values.join(','))
        end
      end
      result[:success] = true
    end
    render status: status, json: result
  end

  def blacklist
    result = {}
    status = 200

    track_id = params[:id].to_i
    if Track.find_by(id: track_id).nil?
      result[:errors] = { id: 'is invalid' }
      result[:success] = false
      status = 400
    else
      $redis.with do |conn|
        blacklisted_ids = conn.get(BLACKLISTED_KEY).split(',').map(&:to_i)
        blacklisted_ids << track_id # add track id to array
        conn.del(BLACKLISTED_KEY)
        conn.set(BLACKLISTED_KEY, blacklisted_ids.join(','))
        keys = conn.keys('next_playlist*')
        keys.each do |key|
          values = conn.get(key).split(',').map(&:to_i)
          values.delete(track_id)
          conn.set(key, values.join(','))
        end
      end
      result[:success] = true
    end
    render status: status, json: result
  end

  def list_all
    result = {}
    status = 200
    tracks = []
    $redis.with do |conn|
      ids = conn.get(BLACKLISTED_KEY)
      if ids.present?
        ids.split(',').map(&:to_i).each do |id|
          tracks << Track.find_by(id: id)
        end
      end
    end
    tracks.compact!

    if tracks.empty?
      result[:success] = false
      result[:errors] = { tracks: 'no blacklisted tracks' }
      status = 400
    else
      result[:tracks] = tracks.map(&:display_helper)
      result[:success] = true
    end
    render status: status, json: result
  end
end
