class V1::PodcastepisodesController < V1::BaseController
  before_action :multiple_ids_handler, only: [:multiple]

  before_action :restrict_only_to_admins, only: [:custom_update]

  def set_progress
    status = 200
    result = {}
    duration = params[:duration].to_i
    id = params[:id]
    episode = Podcastepisode.find_by(id: id)
    key = "#{current_user.id}-#{episode.id}"
    $redis.with do |c|
      c.set(key, duration)
    end
    result[:success] = true
    render status: 200, json: result
  end

  def custom_update
    status = 200
    result = {}

    id = params[:id]
    key = params[:key]
    value = params[:value]
    alterable = %w(title description duration website comedian_ids)

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
      Change.create(data_type: 'episode', data_id: id, values: { key => value })
    end
    render status: status, json: result
  end

  def info
    render status: 200, json: { success: true }
  end

  def show
    result = {}
    status = 200

    id = params[:id]

    episode = Podcastepisode.find_by(id: id)

    if episode.present?
      result[:episode] = episode.display_helper
      result[:episode][:progress] = get_progress(current_user.id, episode.id)
      result[:success] = true
    else
      result[:errors] = { episode: 'does not exist' }
      result[:success] = false
      status = 400
    end
    render status: status, json: result
  end

  def all
    status = 200
    result = {}
    episodes = Podcastepisode.all.order(publish_date: :desc)

    if episodes.count == 0
      status = 400
      result[:success] = false
      result[:errors] = { error: 'there are no podcast episodes' }
    else
      result[:success] = true
      result[:episodes] = []
      episodes.each do |episode|
        entry = episode.display_helper
        entry[:progress] = get_progress(current_user.id, episode.id)
        result[:episodes] << entry
      end
    end
    render status: status, json: result
  end

  def multiple
    result = {}
    status = 200

    if @episodes.present?
      result[:success] = true
      result[:episodes] = []

      @episodes.each do |e|
        entry = e.display_helper
        entry[:progress] = get_progress(current_user.id, e.id)
        result[:episodes] << entry
      end
    else
      status = 400
      result[:success] = false
    end
    result[:errors] = @errors if @errors.present?
    render status: status, json: result
  end

  private

  def get_progress(user_id, id)
    key = "#{user_id}-#{id}"
    duration = 0
    $redis.with do |c|
      duration = c.get(key)
    end
    duration
  end

  def multiple_ids_handler
    ids = params[:ids]
    @errors = {}
    @episodes = []

    if ids.present?
      ids_array = ids.split(',')
      @episodes = []
      ids_array.each do |id_dirty|
        id = id_dirty.to_i
        episode = Podcastepisode.find_by(id: id)
        unless episode.present?
          @errors[id] = 'does not exist'
        end
        @episodes << episode
      end
      @episodes.compact!
    else
      @errors[:ids] = 'are missing'
    end
    @episodes.sort! { |episode1, episode2| episode2.publish_date <=> episode1.publish_date }
  end
end
