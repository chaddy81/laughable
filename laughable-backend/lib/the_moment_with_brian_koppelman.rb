class TheMomentWithBrianKoppelmanParser < FeedburnerParser
    def perform
        #        comedian_ids = []
        #        comedian_ids << Comedian.find_by(name: 'Chelsea Peretti').id
        
        attributes =
        {
            'title' => 'The Moment with Brian Koppelman',
            'summary' => 'Interviews about the pivotal moments that fueled fascinating creative careers. Hosted by Brian Koppelman.',
            'image_url' => 'http://panoply-prod.s3.amazonaws.com/podcasts/320694d6-8289-11e5-b42a-9ff54c4809da/image/PANOPLY150401_panoplyTheMoment1400P.jpg',
            'rss_url' => 'http://feeds.feedburner.com/the-moment',
            #            'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        TheMomentWithBrianKoppelmanParser.perform_in(4.hours)
    end
end
