class NotSafePodcastParser < SoundcloudParser
    def perform
        # comedian_ids = []
        # comedian_ids << Comedian.find_by(name: 'Robert Kelly').id
        attributes =
        {
            'title' => 'Not Safe Podcast',
            'summary' => "Nikki Glaser, host of Comedy Central's Not Safe w/ Nikki Glaser is joined by co-host Dan St. Germain to discuss sex news and personal stories about dating and relationships.",
            'image_url' => 'http://i1.sndcdn.com/avatars-000197587545-wk1i55-original.jpg',
            'rss_url' => 'http://feeds.soundcloud.com/users/soundcloud:users:197681131/sounds.rss'
            # 'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        NotSafePodcastParser.perform_in(4.hours)
    end
end
