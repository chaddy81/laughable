class CallChelseaPerettiParser < FeedburnerParser
    def perform
         comedian_ids = []
         comedian_ids << Comedian.find_by(first_name: 'Chelsea', last_name: 'Peretti').id

        attributes =
        {
            'title' => 'Call Chelsea Peretti',
            'summary' => 'Beloved comedian Chelsea Peretti takes calls on weekly themed episodes, interacts with callers, and contemplates suicide/homicide. Jk.',
            'image_url' => 'https://art19-production.s3-us-west-1.amazonaws.com/images/cb/25/5f/93/cb255f93-40eb-415c-ad13-b3930a234c1d/681489d399a69652e0a5a4ac6419cc7d7938fbfee57eaf92ed2a76297d8119f9d1c8827d961c5a224e7c5a27f1eda6850952269c84c1b3f2382e0d47898417c4.jpeg',
            'rss_url' => 'http://feeds.feedburner.com/CallChelseaPeretti',
             'comedian_ids' => comedian_ids
        }

        run(attributes)
        CallChelseaPerettiParser.perform_in(4.hours)
    end
end
