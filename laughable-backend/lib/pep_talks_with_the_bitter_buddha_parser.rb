class PepTalksWithTheBitterBuddhaParser < FeedburnerParser
    def perform
        #        comedian_ids = []
        #        comedian_ids << Comedian.find_by(name: 'Chelsea Peretti').id
        
        attributes =
        {
            'title' => 'Pep Talks with the Bitter Buddha',
            'summary' => 'A comedic look at our crumbling world with Eddie Pepitone and other funny people.',
            'image_url' => 'http://i1.sndcdn.com/avatars-000058959199-j8nwir-original.jpg',
            'rss_url' => 'http://feeds.feedburner.com/PepTalksPodcast',
            #            'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        PepTalksWithTheBitterBuddhaParser.perform_in(4.hours)
    end
end