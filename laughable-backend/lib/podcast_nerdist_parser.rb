class PodcastNerdistParser < PodcastParser

  def perform
    podcast = Podcast.find_by(title: "The Nerdist")
    feed = podcast.parse_feed
    feed.entries.each do |entry|
      episode = Podcastepisode.find_by(external_id: entry['entry_id'])
      if episode.nil?
        puts "podcast episode titled #{entry['title']} not present, adding"
        clean_duration = clean_up_itunes_duration(entry['itunes_duration'])
        clean_publish_date = entry['published'].to_i
        keywords = feed.itunes_keywords.split(',') if feed.itunes_keywords.present?
        clean_summary = clean_up_description(entry['summary'])
        result =
          {
            stream_url: entry['enclosure_url'],
            external_id: entry['entry_id'],
            duration: clean_duration,
            explicit: entry['itunes_explicit'],
            image_url: entry['itunes_image'],
            description: clean_summary,
            title: entry['title'],
            podcast_id: podcast.id,
            website: entry['url'],
            external_keywords: keywords,
            publish_date: clean_publish_date
          }
        episode = Podcastepisode.new(result)
        episode.save!
      end
    end
    PodcastNerdistParser.perform_in(24.hours)
  end
end
