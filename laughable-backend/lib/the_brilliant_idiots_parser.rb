class TheBrilliantIdiotsParser < SoundcloudParser
    def perform
        # comedian_ids = []
        # comedian_ids << Comedian.find_by(name: 'Robert Kelly').id
        attributes =
        {
            'title' => 'The Brilliant Idiots',
            'summary' => "Charlamagne Tha God and Andrew Schulz are The Brilliant Idiots. Join them each week as they explore the issues of the day in a style that's often idiotic, sometimes brilliant and always hysterical.",
            'image_url' => 'http://i1.sndcdn.com/avatars-000077558236-x3rljg-original.jpg',
            'rss_url' => 'http://feeds.soundcloud.com/users/soundcloud%3Ausers%3A88794716/sounds.rss'
            # 'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        TheBrilliantIdiotsParser.perform_in(4.hours)
    end
end