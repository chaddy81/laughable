class TheBugleParser < FeedburnerParser
    def perform
        #        comedian_ids = []
        #        comedian_ids << Comedian.find_by(name: 'Chelsea Peretti').id
        
        attributes =
        {
            'title' => 'The Bugle',
            'summary' => 'John Oliver and Andy Zaltzman, the transatlantic region’s leading bi-continental satirical double-act, leave no hot potato unbuttered in their worldwide-hit weekly topical comedy show.',
            'image_url' => 'http://i1.sndcdn.com/avatars-000036816294-7qogzv-original.jpg',
            'rss_url' => 'http://feeds.feedburner.com/thebuglefeed',
            #            'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        TheBugleParser.perform_in(4.hours)
    end
end