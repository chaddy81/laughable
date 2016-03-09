class ISeemFunParser < FeedburnerParser
    def perform
#        comedian_ids = []
#        comedian_ids << Comedian.find_by(name: 'Chelsea Peretti').id

        attributes =
        {
            'title' => 'I Seem Fun: The Diary of Jen Kirkman',
            'summary' => 'Jen Kirkman sits in bed, talks to you, well into a microphone about what\'s on her mind.',
            'image_url' => 'http://static.libsyn.com/p/assets/7/8/2/d/782dad0a31230275/ISEEMFUN_ATCcover.jpg',
            'rss_url' => 'http://feeds.feedburner.com/iseemfun'
#            'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        ISeemFunParser.perform_in(4.hours)
    end
end
