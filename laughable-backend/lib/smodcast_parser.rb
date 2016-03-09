class SModcastParser < FeedburnerParser
    def perform
        #        comedian_ids = []
        #        comedian_ids << Comedian.find_by(name: 'Chelsea Peretti').id
        
        attributes =
        {
            'title' => 'SModcast',
            'summary' => 'Podcast by Kevin Smith, Scott Mosier',
            'image_url' => 'http://i1.sndcdn.com/avatars-000069228886-bjj9es-original.jpg',
            'rss_url' => 'http://feeds.feedburner.com/SModcasts',
            #            'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        SModcastParser.perform_in(4.hours)
    end
end
