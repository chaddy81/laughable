class TuesdaysWithStoriesParser < FeedburnerParser
    def perform
#        comedian_ids = []
#        comedian_ids << Comedian.find_by(name: 'Chelsea Peretti').id

        attributes =
        {
            'title' => 'Tuesdays with Stories!',
            'summary' => 'A fun weekly podcast hosted by NYC comedians Joe List and Mark Normand who have an endless amount of funny stories. Every week they spin a few hilarious yarns, sometimes with comedian friends.',
            'image_url' => 'https://art19-production.s3-us-west-1.amazonaws.com/images/b4/a9/88/02/b4a98802-67fb-4215-97a5-efc5d132d5f3/15b329286e38a0df7782ff31c9e92e23647c0821cd34db3fa0b18c956c75838abd16e60768bae3b843458d736f77f99350ed90a7b88620f456f86c9bfee140cb.jpeg',
            'rss_url' => 'http://feeds.feedburner.com/TuesdaysWithStories',
#            'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        TuesdaysWithStoriesParser.perform_in(4.hours)
    end
end
