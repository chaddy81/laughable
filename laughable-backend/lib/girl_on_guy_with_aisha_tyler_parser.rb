class GirlOnGuyParser < LibsynParser
  def perform
    # comedian_ids = []
    # comedian_ids << Comedian.find_by(name: 'Moshe Kasher').id
    # comedian_ids << Comedian.find_by(name: 'Neal Brennan').id

    attributes =
      {
        'title' => 'Girl on Guy with Aisha Tyler',
        'website' => 'http://girlonguy.libsynpro.com/',
        'summary' => 'Join aisha tyler (archer, friends, talk soup) and her guests as they rant about stuff guys love: video games, action movies, comic books, sex, drinking, bar fights, and blowing sh*t up. plus the weekly installments of self-inflicted wounds and \'the apologia\'. girl on guy: stuff. guys. love.',
        'image_url' => 'http://static.libsyn.com/p/assets/8/1/8/d/818d85e9d079cd6b/2013_NEW_LOGO_FIN_SM.jpg',
        'rss_url' => 'http://girlonguy.libsynpro.com/rss'
        # 'comedian_ids' => comedian_ids
      }

    run(attributes)
    GirlOnGuyParser.perform_in(4.hours)
  end
end
