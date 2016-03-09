class LibsynParser < PodcastParser
  def run(attributes)
    podcast = get_podcast(attributes)
    feed = parse_feed(podcast.rss_url)

    feed.entries.each do |entry|
      episode = Podcastepisode.find_by(external_id: entry['entry_id'])
      if episode.nil?
        # Episode doesn't exist yet, let's create it!
        clean_duration = clean_up_itunes_duration(entry['itunes_duration'])
        clean_publish_date = entry['published'].to_i
        keywords = feed.itunes_keywords.split(',') if feed.itunes_keywords.present?
        clean_summary = clean_up_description(entry['summary'])
        explicit = (entry['itunes_explicit'] == 'yes')
        result =
          {
            stream_url: entry['enclosure_url'],
            external_id: entry['entry_id'],
            duration: clean_duration,
            explicit: explicit,
            image_url: entry['itunes_image'],
            description: clean_summary,
            title: entry['title'],
            podcast_id: podcast.id,
            external_keywords: keywords,
            publish_date: clean_publish_date
          }
        Podcastepisode.create(result)
      end
    end
  end
end
