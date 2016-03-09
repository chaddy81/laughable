class TheTimeFerrisShowParser < FeedburnerParser
    def perform
        #        comedian_ids = []
        #        comedian_ids << Comedian.find_by(name: 'Chelsea Peretti').id
        
        attributes =
        {
            'title' => 'The Tim Ferris Show',
            'summary' => 'Tim Ferriss is a self-experimenter and bestselling author, best known for The 4-Hour Workweek, which has been translated into 40+ languages.  Newsweek calls him "the world\'s best human guinea pig," and The New York Times calls him "a cross between Jack Welch and a Buddhist monk."  In this show, he deconstructs world-class performers from eclectic areas (investing, chess, pro sports, etc.), digging deep to find the tools, tactics, and tricks that listeners can use.',
            'image_url' => 'http://static.libsyn.com/p/assets/5/a/8/7/5a87e01004b980c1/TimFerrissShowArt1400x1400.jpg',
            'rss_url' => 'http://feeds.feedburner.com/thetimferrissshow',
            #            'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        TheTimeFerrisShowParser.perform_in(4.hours)
    end
end
