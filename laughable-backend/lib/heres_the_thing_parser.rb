# coding: utf-8
class HeresTheThingParser < FeedburnerParser
    def perform
        #        comedian_ids = []
        #        comedian_ids << Comedian.find_by(name: 'Chelsea Peretti').id

        attributes =
        {
            'title' => 'Here\'s The Thing',
            'summary' => 'Here\'s The Thing is a series of intimate and honest conversations hosted by Alec Baldwin.  Alec talks with artists, policy makers and performers – to hear their stories, what inspires their creations, what decisions changed their careers, and what relationships influenced their work. Check out the full Here\'s The Thing archive.',
            'image_url' => 'https://media2.wnyc.org/i/raw/1/wn16_wnycstudios_Here_The_Thing.jpg',
            'rss_url' => 'http://feeds.wnyc.org/wnycheresthething',
            # 'comedian_ids' => comedian_ids
        }

        run(attributes)
        HeresTheThingParser.perform_in(4.hours)
    end
end
