class V1::PodcastsController < V1::BaseController
  before_action :validate_access_token
  before_action :multiple_ids_handler, only: [:multiple]
  before_action :restrict_only_to_admins, only: [:update, :custom_update,
                                                 :alter_episodes,
                                                 :alter_only_show_featured_episodes]

  def info
    render status: 200, json: { success: true}
  end

  def alter_only_show_featured_episodes
    result = {}
    status = 200
    type = nil
    type = params[:type] if params[:type].present?
    podcast_id = nil
    podcast_id = params[:id].to_i if params[:id].present?
    key = 'GLOBAL_SHOW_FEATURED_ONLY_EPISODES'

    if type.nil? || podcast_id.nil? || podcast_id == 0
      result[:success] = false
      result[:errors] = { parameters: 'need to be specified' }
      status = 400
    else
      ids = ''
      $redis.with { |c| c.get(key) }
      ids_arr = []
      ids_arr = ids.split(',').map(&:to_i) if ids.present?
      if type == 'remove'
        result[:podcast] = "with ID #{podcast_id} successfully removed"
        result[:success] = true
        ids_arr.delete(podcast_id)
      elsif type == 'add'
        result[:podcast] = "with ID #{podcast_id} successfully added"
        result[:success] = true
        ids_arr << podcast_id
      else
        result[:success] = false
        result[:errors] = { parameters: 'type can only be add or remove' }
        status = 400
      end
      $redis.with { |c| c.set(key, ids_arr.join(',')) }
    end

    render status: status, json: result
  end

  def featured_episodes
    result = {}
    podcast_id = params[:id]
    key = "GLOBAL_FEATURED_EPISODES-#{podcast_id}"
    ids = []
    $redis.with do |conn|
      temp = conn.get(key)
      ids = temp.split(',') unless temp.nil?
    end
    episodes = []
    ids.each do |id|
      episodes << Podcastepisode.find_by(id: id)
    end

    result[:success] = true
    result[:episodes] = []
    result[:episodes] = episodes.map(&:display_helper) unless episodes.empty?

    render status: 200, json: result
  end

  def alter_episodes
    status = 200
    result = {}
    podcast_id = params[:id].to_i
    ids = params[:ids]
    if ids.nil?
      status = 400
      result[:success] = false
      result[:errors] = { ids: 'not specified' }
    else
      ids_arr = ids.split(',')
      episodes = []
      ids_arr.each do |id|
        episodes << Podcastepisode.find_by(id: id)
      end
      if episodes.map { |e| e.podcast_id == podcast_id }.all?
        result[:episodes] = episodes.map(&:display_helper)
        result[:success] = true
        $redis.with do |conn|
          key = "GLOBAL_FEATURED_EPISODES-#{podcast_id}"
          conn.set(key, ids)
        end
      else
        status = 400
        errors = {}
        episodes.each do |e|
          error = 'is not part of this podcast'
          errors[e.id] = error unless e.podcast_id == podcast_id
        end
        result[:errors] = errors
        result[:success] = false
      end
    end
    render status: status, json: result
  end

  def custom_update
    status = 200
    result = {}

    id = params[:id]
    key = params[:key]
    value = params[:value]
    alterable = %w(title website summary comedian_ids)

    if id.nil? || key.nil? || value.nil? || !(alterable.include?(key))
      result[:errors] = { params: 'are missing or incorrect' }
      result[:success] = false
      status = 400
    else
      result[:success] = true
      value = value.to_i if key == 'duration'
      if key == 'comedian_ids'
        value_arr = value.split(',')
        value = value_arr.map(&:to_i)
      end
      Change.create(data_type: 'podcast', data_id: id, values: { key => value })
      #c = Podcast.find_by(id: id)
      #value = value.to_i if key == 'duration'
      #value = [value.to_i] if key == 'comedian_ids'
      #c.update(key => value)
    end
    render status: status, json: result
  end

  # List all of the guest podcasters for a specific podcast
  def guests
    status = 200
    result = {}
    id = params[:id].to_i
    podcast = Podcast.find_by(id: id)

    if podcast.present?
      result[:success] = true
      result[:guests] = podcast.guests.map { |id| Comedian.find_by(id: id).display_helper }
      result[:podcast] = podcast.display_helper
    else
      result[:success] = false
      status = 400
      result[:errors] = { podcast: 'does not exist' }
    end
    render status: status, json: result
  end

  def subscribe
    status = 200
    result = {}

    if current_user.present?
      user = current_user
      user.podcast_subscribe(params[:id])
      result[:success] = true
    else
      result[:success] = false
      result[:errors] = { error: 'you need to have an access token to do this' }
      status = 400
    end
    render status: status, json: result
  end

  def unsubscribe
    status = 200
    result = {}

    if current_user.present?
      user = current_user
      user.podcast_unsubscribe(params[:id])
      result[:success] = true
    else
      result[:success] = false
      result[:errors] = { error: 'you need to have an access token to do this' }
      status = 400
    end
    render status: status, json: result
  end

  def all
    status = 200
    result = {}

    podcasts = Podcast.all

    if podcasts.count == 0
      status = 400
      result[:errors] = { error: 'there are no podcasts' }
      result[:success] = false
    else
      result[:podcasts] = []
      result[:success] = true
      podcasts.each do |p|
        result[:podcasts] << p.display_helper
      end
    end
    render status: status, json: result
  end

  def episodes
    result = {}
    status = 200
    id = params[:id]
    podcast = Podcast.find_by(id: id)

    if id.nil?
      result[:success] = false
      result[:errors] = { error: 'id is missing' }
      status = 400
    elsif podcast.nil?
      result[:success] = false
      result[:errors] = { id: "podcast with id #{id} does not exist" }
      status = 400
    else
      result[:success] = true
      episodes = podcast.episodes
      result[:podcast] = podcast.display_helper
      result[:episodes] = []
      episodes.each do |episode|
        result[:episodes] << episode.display_helper
      end
    end

    render status: status, json: result
  end

  def show
    result = {}
    status = 200
    id = params[:id]
    podcast = Podcast.find_by(id: id)
    if podcast.present?
      result[:podcast] = podcast.display_helper
      result[:podcast][:hosts] = podcast.hosts.map(&:display_helper)
      result[:success] = true
    else
      result[:errors] = { id => "the podcast with id #{id} does not exist"}
      result[:success] = false
      status = 400
    end
    render status: status, json: result
  end

  def multiple
    result = {}
    status = 200

    if @podcasts.present?
      result[:success] = true
      result[:podcasts] = []
      @podcasts.each do |p|
        result[:podcasts] << p.display_helper
      end
    else
      status = 400
      result[:success] = false
    end
    result[:errors] = @errors if @errors.present?
    render status: status, json: result
  end

  private

  def multiple_ids_handler
    ids = params[:ids]
    @podcasts = []
    @errors = {}

    if ids.present?
      ids_array = ids.split(',')
      @podcasts = []
      ids_array.each do |id_dirty|
        id = id_dirty.to_i
        podcast = Podcast.find_by(id: id)
        unless podcast.present?
          @errors[id] = 'does not exist'
        end
        @podcasts << podcast
      end
      @podcasts.compact!
    else
      @errors[:ids] = 'are missing'
    end
    @podcasts
  end
end
