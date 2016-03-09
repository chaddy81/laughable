# V1 route base class
# Base controller for V1 routes
class V1::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :track_event
  before_action :rate_limit_check

  def track_event
    result = {}
    result[:params] = {}
    params.keys.each do |key|
      result[:params][key] = params[key]
    end
    result[:timestamp] = Time.now.to_i
    result[:ip] = request.env['HTTP_X_FORWARDED_FOR'] if request.env['HTTP_X_FORWARDED_FOR'].present?
    Event.create(payload: result)
  end

  def validate_access_token
    access_token = params[:access_token]
    if access_token.nil?
      result = {}
      result[:errors] = { access_token:  'is missing' }
      result[:success] = false
      render status: 403, json: result
    else
      api_key = ApiKey.find_by(access_token: access_token)
      if api_key.nil?
        result = {}
        result[:errors] = { access_token: 'is invalid' }
        result[:success] = false
        render status: 403, json: result
      end
    end
  end

  def restrict_only_to_admins
    access_token = params[:access_token]
    errors = {}
    status = 403
    if access_token.nil?
      errors[:access_token] = 'is missing'
    else
      unless ApiKey.find_by(access_token: access_token).user.admin?
        errors[:user] = 'does not have permission to do this'
      end
    end

    render status: status, json: { success: false, errors: errors } unless errors.empty?
  end

  def current_user
    user = User.first
    if params[:access_token].present?
      access_token = params[:access_token]
      api_key = ApiKey.find_by(access_token: access_token)
      user = User.find_by(id: api_key.user_id) unless api_key.nil?
    end
    user
  end

  # If rate limit block should be triggered
  def rate_limit_check
    status = 200
    result = {}
    if rate_limit_on?
      if rate_limit_left > 0
        status = 429
        result[:error] = "you need to wait #{rate_limit_left} ms before you can request anything again"
        render status: status, json: result
      end
    end
  end

  # Time in milliseconds to rate limit
  def rate_limit_add(time)
    access_token = params[:access_token]
    key = "limit-#{access_token}"
    $redis.with do |conn|
      result = conn.set(key, duration)
    end
  end

  private

  def rate_limit_left
    access_token = params[:access_token]
    key = "limit-#{access_token}"
    duration = 0
    $redis.with do |conn|
      duration = conn.get(key)
    end
    duration
  end

  def rate_limit_on?
    result = 0 # For false
    $redis.with do |conn|
      result = conn.get('rate-limit-on')
    end
    result == 1 # True if rate limit is on
  end
end
