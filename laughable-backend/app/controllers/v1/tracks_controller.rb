class V1::TracksController < V1::BaseController
  before_action :validate_access_token
  before_action :multiple_ids_handler, only: [:multiple]

  before_action :restrict_only_to_admins, only: [:custom_update]
  def info
    render status: 200, json: { success: true }
  end

  def custom_update
    status = 200
    result = {}

    id = params[:id]
    key = params[:key]
    value = params[:value]
    alterable = %w(title author duration comedian_id)

    if id.nil? || key.nil? || value.nil? || !(alterable.include?(key))
      result[:errors] = { params: 'are missing or incorrect' }
      result[:success] = false
      status = 400
    else
      result[:success] = true
      Change.create(data_type: 'track', data_id: id, values: { key => value })
      #c = Track.find_by(id: id)
      #value = value.to_i if key == 'duration'
      #c.update(key => value)
    end
    render status: status, json: result
  end

  def multiple
    result = {}
    status = 200

    options = params[:options]
    options_array = options.split(',') if options.present?

    if @tracks.present?
      result[:success] = true
      result[:tracks] = []

      @tracks.each do |t|
        track = t.display_helper(options_array)
        track[:comedian] = t.comedian.display_helper if t.comedian.present?
        result[:tracks] << track
      end
    else
      status = 400
      result[:success] = false
    end
    result[:errors] = @errors if @errors.present?
    render status: status, json: result
  end

  def show
    result = {}
    status = 200

    id = params[:id]
    @errors = []

    track = Track.find_by(id: id)

    if track.present?
      result[:track] = track.display_helper
      comedian = track.comedian
      if Rails.env != 'production'
        change = Change.where(data_type: 'track', data_id: id).last
        if change.present?
          comedian_id = change.values['comedian_id'] if change.values['comedian_id'].present?
          comedian = Comedian.find_by(id: comedian_id)
        end
      end
      result[:track][:comedian] = comedian.display_helper
      result[:success] = true
    else
      result[:errors] = { id => "the track with id #{id} does not exist" }
      status = 400
      result[:success] = false
    end

    render status: status, json: result
  end

  def all
    status = 200
    result = {}
    tracks = []
    tracks = Track.where(staging_only: false) if Rails.env == 'production'
    tracks = Track.all if Rails.env != 'production'

    options = params[:options]
    options_array = options.split(',') if options.present?

    if tracks.count == 0
      status = 400
      result[:errors] = { tracks: 'there are no tracks' }
    else
      result[:tracks] = []
      tracks.each do |track|
        result[:tracks] << track.display_helper(options_array)
      end

      result[:success] = true
    end

    render status: status, json: result
  end

  private

  def multiple_ids_handler
    ids = params[:ids]
    @errors = {}

    if ids.present?
      ids_array = ids.split(',')
      @tracks = []
      ids_array.each do |id_dirty|
        id = id_dirty.to_i
        track = Track.find_by(id: id)
        unless track.present?
          @errors[id] = 'does not exist'
        end
        @tracks << track
      end
      @tracks.compact!
    else
      @errors[:ids] = 'are missing'
    end
  end
end
