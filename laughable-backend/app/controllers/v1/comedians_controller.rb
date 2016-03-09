# V1 version controller
# Comedian controller route
class V1::ComediansController < V1::BaseController
  before_action :validate_access_token
  before_action :validate_comedian_exists, only: [:tracks, :subscribe,
                                                  :unsubscribe, :custom_update,
                                                  :standuptracks,
                                                  :guestpodcastepisodes,
                                                  :hostedpodcasts]

  before_action :update_parameters_handler, only: [:update]
  before_action :multiple_ids_handler, only: [:multiple]

  before_action :restrict_only_to_admins, only: [:update, :custom_update,
                                                 :alter_list]

  def info
    render status: 200, json: { success: true }
  end

  def subscribe
    status = 200
    result = {}
    if current_user.present?
      user = current_user
      user.comedian_subscribe(params[:id])
      result[:success] = true
    else
      result[:success] = false
      result[:errors] = { access_token: 'is missing' }
      status = 400
    end

    render status: status, json: result
  end

  def unsubscribe
    status = 200
    result = {}

    if current_user.present?
      user = current_user
      user.comedian_unsubscribe(params[:id])
      result[:success] = true
    else
      result[:success] = false
      result[:errors] = { access_token: 'is missing' }
      status = 400
    end
    render status: status, json: result
  end

  def tracks
    status = 200
    result = {}

    id = params[:id]
    comedian = Comedian.find_by(id: id, active: true)

    if comedian.nil?
      status = 400
      result[:success] = false
      result[:errors] = { id: "comedian with id #{id} does not exist" }
    else
      result[:success] = true
      result[:comedian] = comedian.display_helper

      result[:tracks] = []
      comedian.tracks.each do |track|
        result[:tracks] << track.display_helper
      end

      result[:count] = comedian.tracks.count
    end

    render status: status, json: result
  end

  def update
    # PUT replaces a resource entirely
    # PATCH updates values in a resource
    status = 200
    result = {}

    if @errors.empty?
      if request.put?
        @comedian.update(@parameters)
      elsif request.patch?
        @parameters.delete_if { |k, v| k.nil? || v.nil? }
        @comedian.update(@parameters)
      end
      result[:success] = true
      result[:comedian] = @comedian.display_helper
    else
      status = 400
      result[:success] = false
      result[:errors] = @errors
    end
    render status: status, json: result
  end

  def all
    status = 200
    result = {}

    comedians = []
    comedians = Comedian.where(active: true, staging_only: false) if Rails.env == 'production'
    comedians = Comedian.where(active: true) if Rails.env != 'production'

    entries = []
    comedians.each do |comedian|
      entries << comedian.display_helper if comedian.present?
    end
    result[:success] = true
    result[:comedians] = entries
    render status: status, json: result
  end

  def multiple
    result = {}
    status = 200

    if @comedians.present?
      result[:success] = true
      result[:comedians] = []

      @comedians.each do |c|
        result[:comedians] << c.display_helper
      end
    else
      status = 400
      result[:success] = false
    end
    result[:errors] = @errors if @errors.present?
    render status: status, json: result
  end

  def show
    status = 200
    result = {}

    id = params[:id]
    comedian = Comedian.find_by(id: id, active: true)
    if comedian.nil?
      status = 400
      result[:success] = false
      result[:errors] = { id => "comedian with id #{id} does not exist" }
    else
      result[:success] = true
      result[:comedian] = comedian.display_helper
    end
    render status: status, json: result
  end

  def alter_list
    result = {}
    status = 200
    comedian_id = nil
    comedian_id = params[:id].to_i if params[:id].present?
    type = nil
    type = params[:type] if params[:type].present?
    key = 'GLOBAL_LISTED_COMEDIANS'

    if comedian_id.nil? || comedian_id == 0 || type.nil?
      result[:success] = false
      result[:errors] = { parameters: 'need to be specified' }
      status = 400
    else
      ids = ''
      $redis.with { |c| ids = c.get(key) }
      ids_arr = []
      ids_arr = ids.split(',').map(&:to_i) if ids.present?
      if type == 'remove'
        result[:comedian] = "with ID #{comedian_id} successfully removed"
        result[:success] = true
        ids_arr.delete(comedian_id)
      elsif type == 'add'
        result[:comedian] = "with ID #{comedian_id} successfully added"
        result[:success] = true
        ids_arr << comedian_id
      else
        result[:success] = false
        result[:errors] = { parameters: 'type can only be add or remove' }
        status = 400
      end
      $redis.with { |c| c.set(key, ids_arr.join(',')) }
    end
    render status: status, json: result
  end

  def list
    status = 200
    result = {}

    comedians = []

    key = 'GLOBAL_LISTED_COMEDIANS'
    ids = []
    ids = get_redis(key).split(',').map(&:to_i) if get_redis(key).present?
    ids.each do |id|
      comedians << Comedian.where(active: true, staging_only: false, id: id).first if Rails.env == 'production'
      comedians << Comedian.where(active: true, id: id).first if Rails.env != 'production'
    end

    entries = []
    comedians.each do |comedian|
      entries << comedian.display_helper if comedian.present?
    end
    result[:success] = true
    result[:comedians] = entries
    render status: status, json: result
  end

  def custom_update
    status = 200
    result = {}

    id = params[:id]
    key = params[:key]
    value = params[:value]
    alterable = %w(first_name last_name biography website twitter_name facebook_name instagram_name)

    if id.nil? || key.nil? || value.nil? || !(alterable.include?(key))
      result[:errors] = { params: 'are missing or incorrect' }
      result[:success] = false
      status = 400
    else
      result[:success] = true
      Change.create(data_type: 'comedian', data_id: id, values: { key => value })
    end
    render status: status, json: result
  end

  def standuptracks
    result = {}
    status = 200

    comedian = Comedian.find_by(id: params[:id], active: true)
    tracks = comedian.tracks
    if tracks.present?
      result[:success] = true
      result[:tracks] = tracks.map(&:display_helper)
      result[:comedian] = comedian.display_helper
    else
      status = 400
      result[:success] = false
      result[:errors] = { comedian: 'has no standup' }
    end

    render status: status, json: result
  end

  def guestpodcastepisodes
    result = {}
    status = 200

    comedian = Comedian.find_by(id: params[:id], active: true)
    episodes = comedian.episodes

    if episodes.present?
      result[:success] = true
      result[:episodes] = episodes.map(&:display_helper)
      result[:comedian] = comedian.display_helper
    else
      status = 400
      result[:success] = false
      result[:errors] = { comedian: 'is not a guest in any podcast episodes' }
    end

    render status: status, json: result
  end

  def hostedpodcasts
    result = {}
    status = 200

    comedian = Comedian.find_by(id: params[:id], active: true)
    podcasts = comedian.podcasts

    if podcasts.present?
      result[:success] = true
      result[:podcasts] = podcasts.map(&:display_helper)
      result[:comedian] = comedian.display_helper
    else
      status = 400
      result[:success] = false
      result[:errors] = { comedian: 'is not hosting any podcasts' }
    end

    render status: status, json: result
  end

  private

  def update_parameters_handler
    @errors = {}
    @parameters = {}
    id = params[:id]
    @comedian = Comedian.find_by(id: id, active: true)
    if @comedian.nil?
      @errors[id] = "comedian with id #{id} does not exist"
    else
      # Explicitly assign parameter values
      @parameters =
        {
          first_name: params[:comedian][:first_name],
          last_name: params[:comedian][:last_name],
          biography: params[:comedian][:biography],
          website: params[:comedian][:website],
          twitter_name: params[:comedian][:twitter_name],
          facebook_name: params[:comedian][:facebook_name],
          instagram_name: params[:comedian][:instagram_name],
          profile_picture: params[:comedian][:profile_picture]
        }
    end
  end

  def multiple_ids_handler
    ids = params[:ids]
    @comedians = []
    @errors = {}

    if ids.present?
      ids.split(',').each do |id_dirty|
        id = id_dirty.to_i
        comedian = Comedian.find_by(id: id, active: true)
        if comedian.present?
          @comedians << comedian
        else
          @errors[id] = 'does not exist'
        end
      end
      @comedians.compact!
    else
      @errors[:ids] = 'are missing'
    end
    @comedians
  end

  def validate_comedian_exists
    comedian = Comedian.find_by(id: params[:id].to_i, active: true)
    render status: 400, json: comedian_does_not_exist if comedian.nil?
  end

  def comedian_does_not_exist
    result = {}
    result[:errors] = { comedian: 'does not exist' }
    result[:success] = false
    result
  end

  def get_redis(key)
    values = ''
    $redis.with { |c| values = c.get(key) }
    values
  end
end
