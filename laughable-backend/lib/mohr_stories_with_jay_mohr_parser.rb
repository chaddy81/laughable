class MohrStoriesWithJayMohrParser < LibsynParser
  def perform
    # comedian_ids = []
    # comedian_ids << Comedian.find_by(name: 'Jay Mohr').id

    attributes =
      {
        'title' => 'Mohr Stories with Jay Mohr',
        'website' => 'http://mohrstories.libsyn.com/',
        'summary' => 'Mohr Stories is hosted by actor, comedian and sports enthusiast, Jay Mohr. The typical format has one celebrity guest that joins Jay in studio to talk about showbiz, comedy and life. Jay\'s guests have included Jay Leno, Charlie Sheen, Mark McGrath, Eric Roberts, Jeremy Guthrie and Rich Eisen. He is a frequent guest on the New York City drive-time radio show "Opie & Anthony," where he adds his own commentary on the bizarre in-studio happenings and of course, throws in the occasional Christopher Walken impersonation.',
        'image_url' => 'http://www.podcastonesales.com/images/podcast/mohrstories.jpg',
        'rss_url' => 'http://www.podcastone.com/podcast?categoryID2=331'
        # 'comedian_ids' => comedian_ids
      }

    run(attributes)
    MohrStoriesWithJayMohrParser.perform_in(4.hours)
  end
end
