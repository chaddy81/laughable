class V1::RecommendationsController < V1::BaseController
  before_action :validate_access_token
  before_action :restrict_only_to_admins, only: [:alter, :info,
                                                 :alter_up_next, :up_next_list,
                                                 :alter_podcastepisode,
                                                 :alter_popularepisodes,
                                                 :schedule_release]

  def info
    render status: 200, json: { success: true }
  end

  def schedule_release
    ChangeTask.perform_async
#    Change.all.map(&:delete)
    render status: 200, json: { success: true }
  end

  def alter_podcastepisode
    result = {}
    status = 200
    errors = {}
    key = 'GLOBAL_PODCAST_EPISODE_SUGGESTION'
    ids = params[:input]

    if ids.present?
      ids_array = ids.split(',').map(&:to_i)
      if ids_array.map { |id| Podcastepisode.exists?(id)}.all?
        $redis.with do |conn|
          conn.del(key)
          conn.set(key, ids_array.join(','))
        end
      else
        errors[:id] = 'one or more ids are invalid'
      end
    else
      errors[:ids] = 'are missing'
    end

    if errors.present?
      result[:success] = false
      status = 400
      result[:errors] = errors
    else
      result[:success] = true
      episodes = ids_array.map do |id|
        Podcastepisode.find_by(id: id).display_helper
      end
      result[:episodes] = episodes
    end
    render status: status, json: result
  end

  def alter_popularepisodes
    result = {}
    status = 200
    errors = {}
    key = 'GLOBAL_POPULAR_EPISODE_SUGGESTION'
    ids = params[:input]

    if ids.present?
      ids_array = ids.split(',').map(&:to_i)
      if ids_array.map { |id| Podcastepisode.exists?(id)}.all?
        $redis.with do |conn|
          conn.del(key)
          conn.set(key, ids_array.join(','))
        end
      else
        errors[:id] = 'one or more ids are invalid'
      end
    else
      errors[:ids] = 'are missing'
    end

    if errors.present?
      result[:success] = false
      status = 400
      result[:errors] = errors
    else
      result[:success] = true
      episodes = ids_array.map do |id|
        Podcastepisode.find_by(id: id).display_helper
      end
      result[:episodes] = episodes
    end
    render status: status, json: result
  end

  def popularepisodes
    #TODO: Combine the short, long, recommended, and podcasts feeds into this.
    # Make all of them be toggle-able by options, and make them dynamic so that
    # it's possible to add and remove feeds easily
    result = {}
    status = 200
    key = 'GLOBAL_POPULAR_EPISODE_SUGGESTION'
    ids_array = redis_get_values(key)

    size = 20
    size = params[:size].to_i if params[:size].present?

    if ids_array.present?
      episodes = []
      ids_array.first(size).each do |id|
        episode = Podcastepisode.find_by(id: id)
        entry = episode.display_helper
        episodes << entry
      end
      result[:success] = true
      result[:episodes] = episodes
    else
      result[:success] = false
      status = 400
      result[:errors] = { episodes: 'are not specified' }
    end
    render status: status, json: result
  end

  def podcastepisode
    result = {}
    status = 200
    key = 'GLOBAL_PODCAST_EPISODE_SUGGESTION'
    ids_array = redis_get_values(key)

    size = 20
    size = params[:size].to_i if params[:size].present?

    if ids_array.present?
      episodes = []
      ids_array.first(size).each do |id|
        episode = Podcastepisode.find_by(id: id)
        entry = episode.display_helper
        episodes << entry
      end
      result[:success] = true
      result[:episodes] = episodes
    else
      result[:success] = false
      status = 400
      result[:errors] = { episodes: 'are not specified' }
    end
    render status: status, json: result
  end

  def banner
    result = {}
    status = 200

    global_key = 'GLOBAL_BANNER_COMEDIAN_IDS'
    comedian_ids = []
    $redis.with do |conn|
      comedian_ids = conn.get(global_key).split(',').map(&:to_i)
    end
    result[:success] = true
    result[:comedians] = []
    comedian_ids.each do |id|
      result[:comedians] << Comedian.find_by(id: id).display_helper(:banner_url)
    end
    render status: status, json: result
  end

  def up_next_list
    result = {}
    status = 200
    ids_array = []
    global_key = 'next_playlist_global'

    $redis.with do |conn|
      ids_array = conn.get(global_key).split(',').map(&:to_i).take(20)
    end

    result[:tracks] = []
    ids_array.each do |id|
      track = Track.find_by(id: id).display_helper
      result[:tracks] << track
    end
    result[:success] = true
    render status: status, json: result
  end

  def alter_up_next
    result = {}
    status = 200
    id = params[:id]
    remove = params[:type] == 'remove'
    global_key = 'next_playlist_global'

    if id.present?
      if remove
        # Remove the playlist in whatever position it currently is,
        # and adds it to the end
        $redis.with do |conn|
          keys = conn.keys('next_playlist_for_user-*')
          keys.each do |key|
            playlist_arr = conn.get(key).split(',').map(&:to_i)
            playlist_arr.delete(id.to_i)
            playlist_arr << id.to_i
            conn.set(key, playlist_arr.join(','))
          end
          playlist_global_arr = conn.get(global_key).split(',').map(&:to_i)
          playlist_global_arr.delete(id.to_i)
          playlist_global_arr << id.to_i
          conn.set(global_key, playlist_global_arr.join(','))
        end
        result[:success] = true
      else
        position = params[:position]
        if position.present?
          position = position.to_i - 1
          $redis.with do |conn|
            keys = conn.keys('next_playlist_for_user-*')
            keys.each do |key|
              playlist_arr = conn.get(key).split(',').map(&:to_i)
              playlist_arr.delete(id.to_i)
              playlist_arr.insert(position, id.to_i)
              conn.set(key, playlist_arr.join(','))
            end
            playlist_global_arr = conn.get(global_key).split(',').map(&:to_i)
            playlist_global_arr.delete(id.to_i)
            playlist_global_arr.insert(position, id.to_i)
            conn.set(global_key, playlist_global_arr.join(','))
          end
          result[:success] = true
        else
          result[:success] = false
          status = 400
          result[:errors] = { position: 'must be present' }
        end
      end
    else
      result[:success] = false
      status = 400
      result[:errors] = { id: 'must be present' }
    end

    render status: status, json: result
  end

  def alter
    result = {}
    status = 200
    errors = {}
    type = params[:type]
    ids = params[:input]
    key = ''

    if type == 'long'
      key = 'GLOBAL_LONG_TRACK_SUGGESTION'
    elsif type == 'short'
      key = 'GLOBAL_SHORT_TRACK_SUGGESTION'
    elsif type == 'recommended'
      key = 'GLOBAL_RECOMMENDED_TRACK_SUGGESTION'
    elsif type.nil?
      errors[:type] = 'is missing'
    end

    if ids.present?
      if ids.split(',').map { |id| Track.exists?(id) }.all?
        $redis.with do |conn|
          conn.del(key)
          conn.set(key, ids)
        end
      else
        errors[:id] = 'one or more ids are invalid'
      end
    else
      errors[:ids] = 'are missing'
    end

    if errors.present?
      result[:success] = false
      status = 400
      result[:errors] = errors
    else
      result[:success] = true
      tracks = ids.split(',').map { |id| Track.find_by(id: id).display_helper }
      result[:tracks] = tracks
      $redis.with do |conn|
        conn.del(key)
        conn.set(key, ids)
      end
    end
    render status: status, json: result
  end

  def short
    result = {}
    status = 200
    key = 'GLOBAL_SHORT_TRACK_SUGGESTION'
    ids_array = redis_get_values(key)

    size = 20
    size = params[:size].to_i if params[:size].present?

    if ids_array.present?
      tracks = []
      ids_array.first(size).each do |id|
        track = Track.find_by(id: id)
        entry = track.display_helper
        entry[:comedian] = track.comedian.display_helper
        tracks << entry
      end
      result[:success] = true
      result[:tracks] = tracks
    else
      result[:success] = false
      status = 400
      result[:errors] = { tracks: 'are not specified' }
    end

    render status: status, json: result
  end

  def long
    result = {}
    status = 200
    key = 'GLOBAL_LONG_TRACK_SUGGESTION'
    ids_array = redis_get_values(key)

    size = 20
    size = params[:size].to_i if params[:size].present?

    if ids_array.present?
      tracks = []
      ids_array.first(size).each do |id|
        track = Track.find_by(id: id)
        entry = track.display_helper
        entry[:comedian] = track.comedian.display_helper
        tracks << entry
      end
      result[:success] = true
      result[:tracks] = tracks
    else
      result[:success] = false
      status = 400
      result[:errors] = { tracks: 'are not specified' }
    end

    render status: status, json: result
  end

  def recommended
    result = {}
    status = 200
    key = 'GLOBAL_RECOMMENDED_TRACK_SUGGESTION'
    ids_array = redis_get_values(key)

    size = 20
    size = params[:size].to_i if params[:size].present?

    if ids_array.present?
      tracks = []
      ids_array.first(size).each do |id|
        track = Track.find_by(id: id)
        entry = track.display_helper
        entry[:comedian] = track.comedian.display_helper
        tracks << entry
      end
      result[:success] = true
      result[:tracks] = tracks
    else
      result[:success] = false
      status = 400
      result[:errors] = { tracks: 'are not specified' }
    end

    render status: status, json: result
  end

  def next
    size = 20
    size = params[:size].to_i if params[:size].present?
    tracks = custom_next_tracks(size)
    result = response_helper(tracks)
    render status: 200, json: result
  end

  private

  def response_helper(tracks)
    result = {}
    result[:tracks] = []
    result[:user] = current_user.display_helper
    tracks.each do |track|
      break if track.nil?
      entry = track.display_helper
      break if track.comedian.nil?
      entry[:comedian] = track.comedian.display_helper
      result[:tracks] << entry
    end
    result[:success] = true
    result
  end

  def custom_next_tracks(size)
    result = []
    playlist_key = "next_playlist_for_user-#{current_user.id}"
    playlist_for_user = []
    $redis.with do |conn|
      res = conn.get(playlist_key)
      res = conn.get('next_playlist_global') if res.nil?
      playlist_for_user = res.split(',').map(&:to_i)
    end

    size.times do
      track_id = playlist_for_user.shift
      playlist_for_user << track_id # Append track at the end
      result << Track.find_by(id: track_id)
    end
    $redis.with do |conn|
      conn.del(playlist_key)
      conn.set(playlist_key, playlist_for_user.join(','))
    end
    result
  end

  def redis_get_values(key)
    result = []
    $redis.with do |conn|
      temp = conn.get(key)
      result = temp.split(',').map(&:to_i) if temp.present?
    end
    result
  end
end
