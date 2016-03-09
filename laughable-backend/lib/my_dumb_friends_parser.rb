class MyDumbFriendsParser < SoundcloudParser
    def perform
        # comedian_ids = []
        # comedian_ids << Comedian.find_by(name: 'Robert Kelly').id
        attributes =
        {
            'title' => 'My Dumb Friends',
            'summary' => "Each week join Dan St. Germain and Sean Donnelly while they hang out with their funny friends and talk about the dumbest stuff they’ve ever done. Produced (and often co-hosted) by Thomas Attila Lewis.",
            'image_url' => 'http://i1.sndcdn.com/avatars-000066414499-zdaydq-original.jpg',
            'rss_url' => 'http://feeds.soundcloud.com/users/soundcloud:users:66989075/sounds.rss'
            # 'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        MyDumbFriendsParser.perform_in(4.hours)
    end
end
