class RaceWarsParser < FeedburnerParser
    def perform
        #        comedian_ids = []
        #        comedian_ids << Comedian.find_by(name: 'Chelsea Peretti').id

        attributes =
        {
            'title' => 'Race Wars',
            'summary' => 'Hilarious, honest, and unfiltered, hosts with Kurt Metzger and Sherrod Small deliver a brutally funny perspective that can’t be found anywhere else, cutting through all the layers of politically correct media spin to deliver hysterical and truthful opinions on social, racial, and global topics.',
            'image_url' => 'https://art19-production.s3-us-west-1.amazonaws.com/images/d8/10/c6/96/d810c696-f939-4941-8928-68796548ae35/c2d6df38463fcd4d51f0dd3977331f08ff98705547107e2b6a5e94b597793b4fb8815d27e47960e6fcf9ed8eb2884e838202c52e50e20d15d45185c816dffedd.jpeg',
            'rss_url' => 'http://feeds.feedburner.com/RaceWarsPodcast',
            #            'comedian_ids' => comedian_ids
        }

        run(attributes)
        RaceWarsParser.perform_in(4.hours)
    end
end
