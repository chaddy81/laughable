class StopPodcastingYourselfParser < FeedburnerParser
    def perform
        #        comedian_ids = []
        #        comedian_ids << Comedian.find_by(name: 'Chelsea Peretti').id
        
        attributes =
        {
            'title' => 'Stop Podcasting Yourself',
            'summary' => 'Canada\'s top comedy podcast. Hosted by Graham Clark and Dave Shumka, with weekly guests. Hilarious weekly guests? Yup.',
            'image_url' => 'http://static.libsyn.com/p/assets/b/f/8/8/bf887c72706273f9/spybrakes1400.jpg',
            'rss_url' => 'http://feeds.feedburner.com/stoppodcastingyourself',
            #            'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        StopPodcastingYourselfParser.perform_in(4.hours)
    end
end
