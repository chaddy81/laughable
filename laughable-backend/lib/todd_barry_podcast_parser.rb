class ToddBarryPodcastParser < PodcastParser
  def perform
    podcast = Podcast.find_by(title: "The Todd Barry Podcast")
    feed = podcast.parse_feed
    feed.entries.each do |entry|
      episode = Podcastepisode.find_by(external_id: entry['entry_id'])
      if episode.nil?
        puts "podcast episode titled #{entry['title']} not present, adding"
        clean_duration = clean_up_itunes_duration(entry['itunes_duration'])
        clean_publish_date = entry['published'].to_i
        clean_summary = clean_up_description(entry['summary'])
        explicit = (entry['itunes_explicit'] == 'yes')
        result =
          {
            stream_url: entry['enclosure_url'],
            external_id: entry['entry_id'],
            duration: clean_duration,
            explicit: explicit,
            image_url: nil,
            description: clean_summary,
            title: entry['title'],
            podcast_id: podcast.id,
            website: entry['url'],
            publish_date: clean_publish_date
          }
        episode = Podcastepisode.new(result)
        episode.save!
      end
    end
    ToddBarryPodcastParser.perform_in(24.hours)
  end
end
