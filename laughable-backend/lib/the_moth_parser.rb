class TheMothParser < FeedburnerParser
    def perform
        #        comedian_ids = []
        #        comedian_ids << Comedian.find_by(name: 'Chelsea Peretti').id
        
        attributes =
        {
            'title' => 'The Moth Podcast',
            'summary' => 'Since its launch in 1997, The Moth has presented thousands of true stories, told live and without notes, to standing-room-only crowds worldwide. Moth storytellers stand alone, under a spotlight, with only a microphone and a roomful of strangers. The storyteller and the audience embark on a high-wire act of shared experience which is both terrifying and exhilarating. Since 2008, The Moth podcast has featured many of our favorite stories told live on Moth stages around the country. For information on all of our programs and live events, visit themoth.org.',
            'image_url' => 'http://cdn.themoth.prx.org/wp-content/uploads/powerpress/moth_podcast_prx_480x480.jpeg',
            'rss_url' => 'http://feeds.themoth.org/themothpodcast',
            #            'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        TheMothParser.perform_in(4.hours)
    end
end
