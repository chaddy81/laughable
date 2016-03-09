class TenMinutePodcastParser < FeedburnerParser
    def perform
        #        comedian_ids = []
        #        comedian_ids << Comedian.find_by(name: 'Chelsea Peretti').id
        
        attributes =
        {
            'title' => 'Ten Minute Podcast',
            'summary' => 'Join Will Sasso (MADtv, The Three Stooges, lots of other stuff) as he and his funny pals do lots of super fun bits, jump into some silly characters and impersonations, and ruthlessly belittle one another for real the way only good friends can. Ten Minute Podcast is recess for adults. Pass it on!',
            'image_url' => 'http://static.libsyn.com/p/assets/9/1/f/0/91f0fe637cbc9818/tenminpod_1600x1600.jpg',
            'rss_url' => 'http://feeds.feedburner.com/TenMinutePodcast',
            #            'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        TenMinutePodcastParser.perform_in(4.hours)
    end
end
