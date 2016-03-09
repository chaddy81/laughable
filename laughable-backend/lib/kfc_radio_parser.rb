class KfcRadioParser < FeedburnerParser
    def perform
        #        comedian_ids = []
        #        comedian_ids << Comedian.find_by(name: 'Chelsea Peretti').id
        
        attributes =
        {
            'title' => 'KFC Radio',
            'summary' => 'Featuring all of the regular Barstool personalities, KFC Radio is the quintessential bar conversation brought to podcast form. Listener interaction is the name of the game as Barstool readers and listeners contribute their Stoolie Voicemails to drive the conversation to strange places including embarrassing personal stories, bizarre hypothetical questions, and more. New episodes of the hilarious Barstool Network flagship show are released every Friday.',
            'image_url' => 'http://boston.barstoolsports.com/wp-content/blogs.dir/2/files/2014/05/KFCRadio.jpg',
            'rss_url' => 'http://feeds.feedburner.com/barstoolkfcradio',
            #            'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        KfcRadioParser.perform_in(4.hours)
    end
end