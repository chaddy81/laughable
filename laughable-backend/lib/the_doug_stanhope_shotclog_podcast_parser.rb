class TheDougStanhopeShotclogPodcastParser < LibsynParser
  def perform
    # comedian_ids = []
    # comedian_ids << Comedian.find_by(name: 'Christina Pazsitzky').id
    # comedian_ids << Comedian.find_by(name: 'Tom Segura').id

    attributes =
      {
        'title' => 'The Doug Stanhope Shotclog Podcast',
        'website' => 'http://stanhope.libsyn.com/',
        'summary' => 'Doug Stanhope hosts discussions with individuals he meets on the road and at home in Bisbee, AZ.',
        'image_url' => 'http://static.libsyn.com/p/assets/3/9/a/1/39a1b8c81fa0f7f8/shotclog-podcast-1400.jpg',
        'rss_url' => 'http://stanhope.libsyn.com/rss'
        # 'comedian_ids' => comedian_ids
      }

    run(attributes)
    TheDougStanhopeShotclogPodcastParser.perform_in(4.hours)
  end
end
