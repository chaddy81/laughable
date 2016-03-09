class JudgeJohnHodgmanParser < FeedburnerParser
    def perform
#        comedian_ids = []
#        comedian_ids << Comedian.find_by(name: 'Chelsea Peretti').id

        attributes =
        {
            'title' => 'Judge John Hodgman',
            'summary' => 'John Hodgman\'s Today in the Past podcast is now The Judge John Hodgman Podcast.  Have your pressing issues decided by Famous Minor Television Personality John Hodgman, Certified Judge.  If you\'d like John Hodgman to solve your pressing issue, simply email it, along with your phone number, to hodgman@maximumfun.org.  THAT IS ALL.',
            'image_url' => 'http://static.libsyn.com/p/assets/a/9/3/a/a93a1d094735ef9c/judge-john-hodgman-square-mustache.jpg',
            'rss_url' => 'http://feeds.feedburner.com/todayinthepast',
#            'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        JudgeJohnHodgmanParser.perform_in(4.hours)
    end
end
