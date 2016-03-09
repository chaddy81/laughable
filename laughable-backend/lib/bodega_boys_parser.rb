class BodegaBoysParser < SoundcloudParser
    def perform
        # comedian_ids = []
        # comedian_ids << Comedian.find_by(name: 'Robert Kelly').id
        attributes =
        {
            'title' => 'Bodega Boys',
            'summary' => "Desus Nice (@Desusnice) and The Kid Mero (@thekidmero) are the Bodega Boys https://twitter.com/BodegaBoys",
            'image_url' => 'http://i1.sndcdn.com/avatars-000174316582-230oru-original.jpg',
            'rss_url' => 'http://feeds.soundcloud.com/users/soundcloud:users:169774121/sounds.rss'
            # 'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        BodegaBoysParser.perform_in(4.hours)
    end
end