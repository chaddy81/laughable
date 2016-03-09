class V1::ShortenerController < V1::BaseController

  def track
    result = {}
    status = 200
    track_id = params[:track_id]
    quality = 'low'
    quality = params[:quality] if params[:quality].present?

    if track_id.nil?
      result[:success] = false
      result[:errors] = { track_id: 'needs to be specified' }
      status = 400
    else
      track = Track.find_by(id: track_id)
      if track.nil?
        status = 400
        result[:success] = false
        result[:errors] = { track_id => "track with id #{track_id} does not exist" }
      else
        # TODO: Add tracking of owner and person requesting this URL
        if quality == 'low'
          result[:url] = "#{ENV['MEDIA_FILE_URL']}/#{Shortener::ShortenedUrl.generate(track.proper_low_stream_url).unique_key}"
        elsif quality == 'high'
          result[:url] = "#{ENV['MEDIA_FILE_URL']}/#{Shortener::ShortenedUrl.generate(track.proper_high_stream_url).unique_key}"
        elsif quality == 'medium'
          result[:url] = "#{ENV['MEDIA_FILE_URL']}/#{Shortener::ShortenedUrl.generate(track.proper_medium_stream_url).unique_key}"
        end
        result[:success] = true
      end
    end
    render status: status, json: result
  end
end
