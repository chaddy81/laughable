class Podcastepisode < ActiveRecord::Base

  def display_helper
    result = {}
    default = [:id, :title, :stream_url, :description, :duration,
               :explicit, :external_keywords, :publish_date]
    default.each { |attribute| result[attribute] = send(attribute) }

    change = Change.where(data_type: 'episode', data_id: send(:id)).last if Rails.env != 'production'
    if change.present?
      change.values.keys.each do |key|
        result[key] = change.values[key] unless key == 'comedian_ids'
      end if Rails.env != 'production'
    end

    comedian_ids = send(:comedian_ids)
    comedian_ids = change.values['comedian_ids'] if change.present? && change.values['comedian_ids'].present? && Rails.env != 'production'
    podcast_id = send(:podcast_id)
    podcast_id = change.values['podcast_id'] if change.present? && change.values['podcast_id'].present? && Rails.env != 'production'
    result[:guests] = guests_display(comedian_ids)
    result[:podcast] = podcast_display(podcast_id)
    result
  end

  def podcast
    Podcast.find_by(id: send(:podcast_id))
  end

  def hosts
    podcast.podcaster_ids.map { |id| Podcaster.find_by(id: id) }
  end

  private

  def podcast_display(podcast_id)
    podcast = Podcast.find_by(id: podcast_id)
    result = podcast.display_helper
    result[:hosts] = []
    podcast.hosts.each do |host|
      result[:hosts] << host.display_helper
    end
    result
  end

  def guests_display(ids_array)
    comedians = []
    return comedians unless ids_array.present?
    return comedians unless ids_array.map { |id| Comedian.exists?(id) }.all?
    ids_array.each do |id|
      comedians << Comedian.find_by(id: id).display_helper
    end
    comedians
  end
end
