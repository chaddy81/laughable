class PodcastParser
  include Sidekiq::Worker


  def get_podcast(attributes)
    title = attributes['title']
    rss_url = attributes['rss_url']

    podcast = Podcast.where(title: title, rss_url: rss_url)
    # Return existing podcast
    return podcast.first if podcast.present?
    # Since podcast doesn't exist, we need to create it and return it instead
    create_podcast(attributes)
  end

  def create_podcast(attributes)
    podcast = Podcast.new

    # The title of the podcast
    podcast.title = attributes['title']
    # The summary of the podcast
    podcast.summary = attributes['summary']
    # The location of the podcast image
    podcast.image_url = attributes['image_url']
    # The URL for the RSS feed
    podcast.rss_url = attributes['rss_url']
    # The IDs of the comedians hosting the podcast if it's known
    podcast.comedian_ids = attributes['comedian_ids'] if attributes.include?('comedian_ids')
    # Make the podcast staging only
    podcast.staging_only = true

    # Save the object to the database
    podcast.save!
    # Return the object
    podcast
  end

  def parse_feed(string = nil)
    require 'uri'
    return nil if string.nil?
    feed = nil
    Feedjira::Feed.add_common_feed_element('itunes:keywords', as: :keywords)
    Feedjira::Feed.add_common_feed_entry_element('itunes:duration', as: :duration)
    Feedjira::Feed.add_common_feed_entry_element('itunes:explicit', as: :explicit)
    Feedjira::Feed.add_common_feed_element('itunes:image', as: :image)

    if string =~/\A#{URI::regexp}\z/
      feed = Feedjira::Feed.fetch_and_parse(string)
    else
      feed = Feedjira::Feed.parse(string)
    end
    feed
  end

  def clean_up_description(text)
    ActionView::Base.full_sanitizer.sanitize(text)
  end

  def clean_up_itunes_duration(duration_str)
    result = 0
    return result if duration_str.nil?
    split_int = duration_str.split(':').map(&:to_i)
    if split_int.count == 3
      result = (((split_int[0] * 60) + split_int[1]) * 60 + split_int[2])
    elsif split_int.count == 2
      result = (split_int[0] * 60) + split_int[1]
    elsif split_int.count == 1
      result = split_int[0]
    end
    result
  end
end
