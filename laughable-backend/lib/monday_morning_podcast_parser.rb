class MondayMorningPodcastParser < LibsynParser
    def perform
         comedian_ids = []
         comedian_ids << Comedian.find_by(first_name: 'Bill', last_name: 'Burr').id

        attributes =
        {
            'title' => 'Monday Morning Podcast',
            'summary' => 'Bill Burr rants about relationship advice, sports and the Illuminati.',
            'image_url' => 'http://static.libsyn.com/p/assets/4/7/9/b/479b005a1d9a6fe6/Burr_image-062.jpg',
            'rss_url' => 'http://billburr.libsyn.com/rss',
            'comedian_ids' => comedian_ids
        }

        run(attributes)
        MondayMorningPodcastParser.perform_in(4.hours)
    end
end
