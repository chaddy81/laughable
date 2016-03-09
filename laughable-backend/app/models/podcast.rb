class Podcast < ActiveRecord::Base

  def display_helper
    result = {}
    default = [:id, :title, :summary]
    default.each { |attribute| result[attribute] = send(attribute) }
    change = Change.where(data_type: 'podcast', data_id: send(:id)).last if Rails.env != 'production'
    if change.present?
      change.values.keys.each do |key|
        result[key] = change.values[key]
      end if Rails.env != 'production'
    end
    result[:profile_picture] = [send(:image_url)]
    result[:has_guests] = guests?
    result[:has_featured_episodes] = featured_episodes?
    result[:only_show_featured_episodes] = only_show_featured_episodes?
    result
  end

  def only_show_featured_episodes?
    key = "GLOBAL_SHOW_FEATURED_ONLY_EPISODES"
    ids = ''
    $redis.with { |c| ids = c.get(key) }
    ids_arr = []
    ids_arr = ids.split(',').map(&:to_i) if ids.present?
    ids_arr.include?(send(:id))
  end

  def featured_episodes?
    key = "GLOBAL_FEATURED_EPISODES-#{send(:id)}"
    ids = nil
    $redis.with { |c| ids = c.get(key) }
    ids.present?
  end

  def guests?
    Podcastepisode.where(podcast_id: send(:id)).where.not("comedian_ids = '{}'").present?
  end

  # The parse of the corresponding RSS feed
  # Returns a Feedjira::Parser object
  def parse_feed
    url = send(:rss_url)
    if url.present?
      Feedjira::Feed.fetch_and_parse(url)
    else
      #TODO: Alert hubot that feed is invalid
    end
  end

  def guests
    Podcastepisode.where(podcast_id: send(:id)).where.not("comedian_ids = '{}'").pluck(:comedian_ids).flatten.uniq
  end

  def episodes
    Podcastepisode.where(podcast_id: send(:id)).order(publish_date: :desc)
  end

  def hosts
    send(:comedian_ids).map { |id| Comedian.find_by(id: id) }
  end
end
