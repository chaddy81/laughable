class TheChampsParser < LibsynParser
  def perform
    # comedian_ids = []
    # comedian_ids << Comedian.find_by(name: 'Moshe Kasher').id
    # comedian_ids << Comedian.find_by(name: 'Neal Brennan').id

    attributes =
      {
        'title' => 'The Champs with Neal Brennan + Moshe Kasher',
        'website' => 'http://thechamps.libsyn.com/',
        'summary' => 'Neal Brennan (Chappelle\'s Show), and Moshe Kasher (Chelsea Lately) welcome a different (black) guest every week to the podcast to discuss stupid things in a stupid way.',
        'image_url' => 'http://static.libsyn.com/p/assets/b/e/7/4/be743cc736d9e060/Champs_ATCcover2.jpg',
        'rss_url' => 'http://thechamps.libsyn.com/rss',
        # 'comedian_ids' => comedian_ids
      }

    run(attributes)
    TheChampsParser.perform_in(4.hours)
  end
end
