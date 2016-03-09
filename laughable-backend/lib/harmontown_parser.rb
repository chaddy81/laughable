class HarmontownParser < FeedburnerParser
    def perform
        #        comedian_ids = []
        #        comedian_ids << Comedian.find_by(name: 'Chelsea Peretti').id

        attributes =
        {
            'title' => 'Harmontown',
            'summary' => 'Self destructive writer Dan Harmon ("Community," "Monster House," "Heat Vision and Jack") claims he will one day found a colony of like-minded misfits.  He\'s appointed suit-clad gadabout Jeff Davis ("Whose Line is it Anyway") as his Comptroller.',
            'image_url' => 'https://art19-production.s3-us-west-1.amazonaws.com/images/89/a3/a0/38/89a3a038-05d1-494d-b1e1-0c4767fccdd8/675f78e08433fc7acfa1d068f9455065988e39d6676f6570e99b295f832fe96c8a6df5bb8d06873a33266c5f66b47cce870543d99e9bf3e7d88d780d6475a373.jpeg',
            'rss_url' => 'https://feeds.feedburner.com/HarmontownPodcast',
            #            'comedian_ids' => comedian_ids
        }

        run(attributes)
        HarmontownParser.perform_in(4.hours)
    end
end
