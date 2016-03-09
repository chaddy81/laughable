class V1::ContentsController < V1::BaseController
  skip_before_filter :verify_authenticity_token

  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers

  def upload
    file = params[:media] if params[:media].present?
    uploader = ContentUploader.new

    status = 200
    result = {}

    uploader.store!(file)
    result[:success] = true
    render status: status, json: result
  end

  def create
    status = 200
    result = {}
    personal_info = {}
    track_list = {}

    personal_info = params[:personal_info] if params[:personal_info].present?
    track_list = params[:track_list] if params[:track_list].present?

    result[:personal_info] = personal_info
    result[:track_list] = track_list

    cms = Cmscontent.create(entry: result)

    if (personal_info.present?) && (track_list.present?)
      track_list.each do |t|
        puts "\n debug: t is #{t} of class #{t.class}"
        alert = {}
        alert['first_name'] = personal_info['first_name']
        alert['last_name'] = personal_info['last_name']
        alert['cms_id'] = cms.id
        alert['track_name'] = t[1]['name']
        alert['do_not_clip'] = t[1]['doNotClip']
        alert['clip_start'] = t[1]['start']
        alert['clip_end'] = t[1]['end']

        ContentSubmissionAlert.perform_async(alert)
      end
    end

    render status: status, json: { success: true }
  end

  def authenticate
    code = params[:code]
    result = {}
    status = 200
    if matches_the_secret?(code)
      result[:success] = true
    else
      status = 400
      result[:success] = false
      result[:error] = 'invalid code'
    end
    alert_the_bot_about_authentication(result, code)
    render status: status, json: result
  end
  private

  def alert_the_bot_about_authentication(result, code)
    response_str = 'unsuccessful'
    response_str = 'successful' if result[:success]
    ip = request.env["HTTP_X_FORWARDED_FOR"]
    response_hash = { code: code, success: response_str, ip: ip }

    SubmissionKeywordAlert.perform_async(response_hash)
  end

  def matches_the_secret?(code)
    secret_words = []
    $redis.with do |conn|
      secret_words = conn.smembers('cms-secret-words')
    end
    secret_words.include?(code)
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def cors_preflight_check
    if request.method == 'OPTIONS'
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'Cache-Control, X-Requested-With, X-Prototype-Version, Token'
      headers['Access-Control-Max-Age'] = '1728000'

      render :text => '', :content_type => 'text/plain'
    end
  end
end
