class TheComediansComedianPodcastParser < FeedburnerParser
    def perform
        #        comedian_ids = []
        #        comedian_ids << Comedian.find_by(name: 'Chelsea Peretti').id
        
        attributes =
        {
            'title' => 'The Comedian\'s Comedian Podcast',
            'summary' => 'How do today\'s stand-up comedy stars go from a blank piece of paper to a fully-formed Edinburgh show or DVD?  In each show, comedian Stuart Goldsmith interviews a comedy headliner in depth, about exactly how they make funny stuff from scratch. Comics are used to being asked “where do you get your ideas?”, but The Comedian\'s Comedian Podcast goes further, asking: How much of your real self is there in your persona? How much new stuff can you get away with jamming into a club set? How do you shape a set-list? What\'s your methodology? Have you got a methodology? Why haven\'t you got a methodology? For people who perform comedy, write comedy, enjoy comedy, or have an interest in comedians and what makes them so annoying. Part interview, part master-class, part therapy - this is The Comedian\'s Comedian Podcast.',
            'image_url' => 'http://imglogo.podbean.com/image-logo/315131/ccpnewimagesqitunes.jpg',
            'rss_url' => 'http://feeds.feedburner.com/stuartgoldsmith',
            #            'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        TheComediansComedianPodcastParser.perform_in(4.hours)
    end
end
