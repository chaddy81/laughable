class WtfMarkMaronParser < PodcastParser
  PODCAST_URI = "http://www.wtfpod.com/podcast/rss"

  def perform
    podcast = Podcast.find_by(title: "WTF with Marc Maron")
    feed = podcast.parse_feed
    feed.entries.each do |entry|
      episode = Podcastepisode.find_by(external_id: entry['entry_id'])
      if episode.nil?
        puts "podcast episode titled #{entry['title']} not present, adding"
        clean_duration = clean_up_itunes_duration(entry['itunes_duration'])
        clean_publish_date = entry['published'].to_i
        clean_summary = clean_up_description(entry['summary'])
        result =
          {
            stream_url: entry['image'],
            external_id: entry['entry_id'],
            duration: clean_duration,
            explicit: true,
            image_url: "https://upload.wikimedia.org/wikipedia/en/8/8f/WTF_with_Marc_Maron.png",
            description: clean_summary,
            title: entry['title'],
            podcast_id: podcast.id,
            website: entry['url'],
            publish_date: clean_publish_date
          }
        Podcastepisode.create(result)
      end
    end
    WtfMarkMaronParser.perform_in(4.hours)
  end
end
