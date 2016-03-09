class FeedburnerParser < PodcastParser
  def run(attributes)
    podcast = get_podcast(attributes)
    feed = parse_feed(podcast.rss_url)

    feed.entries.each do |entry|
      episode = Podcastepisode.find_by(external_id: entry['entry_id'])
      if episode.nil?
        clean_duration = clean_up_itunes_duration(entry['duration'])
        clean_publish_date = entry['published'].to_i
        clean_summary = clean_up_description(entry['summary'])
        explicit = (entry['explicit'] == 'yes')
        result =
          {
            stream_url: entry['image'],
            external_id: entry['entry_id'],
            duration: clean_duration,
            explicit: explicit,
            description: clean_summary,
            title: entry['title'],
            podcast_id: podcast.id,
            publish_date: clean_publish_date,
            staging_only: true
          }
        Podcastepisode.create(result)
      end
    end
  end
end
