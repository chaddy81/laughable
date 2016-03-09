class ComeToPapaParser < FeedburnerParser
    def perform
        #        comedian_ids = []
        #        comedian_ids << Comedian.find_by(name: 'Chelsea Peretti').id
        
        attributes =
        {
            'title' => 'COME TO PAPA',
            'summary' => 'World Famous Comedian Tom Papa sits down with his friends, who are also World Famous Comedians. Join him and the biggest names in comedy as they discuss stand up, life, or whatever the hell they feel like.',
            'image_url' => 'http://i1.sndcdn.com/avatars-000068520496-lp4ypj-original.jpg',
            'rss_url' => 'http://feeds.feedburner.com/soundcloud/CTP',
            #            'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        ComeToPapaParser.perform_in(4.hours)
    end
end
