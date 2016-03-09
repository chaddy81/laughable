class Track < ActiveRecord::Base
  belongs_to :comedian

  after_create { RedisUpNextUpdate.perform_async('add', id) }
  after_destroy { RedisUpNextUpdate.perform_async('delete', id) }

  def display_helper(options = [])
    result = {}
    default = [:id, :title, :author, :description, :duration,
               :comedian_id]

#    default += [options] if options.present?
#    default.uniq!
#    default.flatten!
    default.each { |attribute| result[attribute] = send(attribute) }
    change = Change.where(data_type: 'track', data_id: send(:id)).last if Rails.env != 'production'
    if change.present?
      change.values.keys.each do |key|
        result[key] = change.values[key]
      end if Rails.env != 'production'
    end
    result[:high_stream_url] = proper_high_stream_url
    result[:medium_stream_url] = proper_medium_stream_url
    result[:low_stream_url] = proper_low_stream_url

    result
  end

  def comedian
    Comedian.find_by(id: send(:comedian_id))
  end

  def proper_high_stream_url
    url = "#{ENV['MEDIA_FILE_URL']}#{send(:high_stream_url)}"
    url
  end

  def proper_medium_stream_url
    url = "#{ENV['MEDIA_FILE_URL']}#{send(:medium_stream_url)}"
    url
  end

  def proper_low_stream_url
    url = "#{ENV['MEDIA_FILE_URL']}#{send(:low_stream_url)}"
    url
  end
end
