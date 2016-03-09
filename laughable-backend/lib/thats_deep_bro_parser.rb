class ThatsDeepBroParser < LibsynParser
  def perform
    # comedian_ids = []
    # comedian_ids << Comedian.find_by(name: 'Tom Segura').id

    attributes =
      {
        'title' => 'That\'s Deep Bro',
        'website' => 'http://thatsdeepbro.libsyn.com/webpage',
        'summary' => 'That\'s Deep, Bro is a podcast hosted by comedian Christina Pazsitzky that combines philosophy and comedy. Very serious questions with supremely silly people.',
        'image_url' => 'http://static.libsyn.com/p/assets/5/b/3/2/5b324f112be06678/Cp_TDB.jpg',
        'rss_url' => 'http://thatsdeepbro.libsyn.com/rss'
        # 'comedian_ids' => comedian_ids
      }

    run(attributes)
    ThatsDeepBroParser.perform_in(4.hours)
  end
end
