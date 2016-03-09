class TheAdamAndDrDrewShowParser < FeedburnerParser
    def perform
        #        comedian_ids = []
        #        comedian_ids << Comedian.find_by(name: 'Chelsea Peretti').id
        
        attributes =
        {
            'title' => 'The Adam and Dr. Drew Show',
            'summary' => 'Adam Carolla & Dr. Drew Pinsky reunite the partnership that made Loveline a wild success and cultural touchstone.  In each episode Adam and Drew take uncensored, nothing-off-limits, calls about sex, drug, medical and relationship issues. Dr. Drew brings the medicine while Adam\'s comedy and rants are the spoonful of sugar to make it go down.',
            'image_url' => 'http://ace.noxsolutions.com/images/podcast/adamanddrew.jpg',
            'rss_url' => 'http://feeds.feedburner.com/TheAdamAndDrewShow',
            #            'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        TheAdamAndDrDrewShowParser.perform_in(4.hours)
    end
end
