class MyBrotherMyBrotherAndMeParser < FeedburnerParser
    def perform
        #        comedian_ids = []
        #        comedian_ids << Comedian.find_by(name: 'Chelsea Peretti').id
        
        attributes =
        {
            'title' => 'My Brother, My Brother And Me',
            'summary' => 'Free advice from three of the world\'s most qualified, most related experts: Justin, Travis and Griffin McElroy. For one-half to three-quarters of an hour every Monday, we tell people how to live their lives, because we\'re obviously doing such a great job of it so far.',
            'image_url' => 'http://static.libsyn.com/p/assets/6/d/7/d/6d7d36d6929db515/MBMBAM_Update.jpg',
            'rss_url' => 'http://feeds.feedburner.com/mbmbam',
            #            'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        MyBrotherMyBrotherAndMeParser.perform_in(4.hours)
    end
end
