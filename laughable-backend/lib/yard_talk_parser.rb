class YardTalkParser < SoundcloudParser
    def perform
        # comedian_ids = []
        # comedian_ids << Comedian.find_by(name: 'Robert Kelly').id
        attributes =
        {
            'title' => 'Yard Talk',
            'summary' => "Comedian Mike Yard sits down with co-hosts Luna Tee, and Carla Keyz for conversations about everything and anything under the sun.",
            'image_url' => 'http://i1.sndcdn.com/avatars-000174030737-4ql40o-original.jpg',
            'rss_url' => 'http://feeds.soundcloud.com/users/soundcloud:users:145647614/sounds.rss'
            # 'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        YardTalkParser.perform_in(4.hours)
    end
end
