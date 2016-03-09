class TheAdamCarollaShowParser < LibsynParser
  def perform
    # comedian_ids = []
    # comedian_ids << Comedian.find_by(name: 'Tom Segura').id

    attributes =
      {
        'title' => 'The Adam Carolla Show',
        'website' => 'http://www.adamcarolla.com',
        'summary' => 'The Adam Carolla Show is the #1 Daily Downloaded Podcast in the World. GET IT ON as Adam shares his thoughts on current events, relationships, airport security, specialty pizzas, hobos, and anything else he can complain about. Five days a week and completely uncensored, Adam welcomes a wide range of guests to join him on the couch for in depth interviews and a front row seat to his unparalleled ranting. Let\'s not forget Bryan Bishop (Bald Bryan) on sound effects.',
        'image_url' => 'http://static.libsyn.com/p/assets/d/e/2/9/de291a38a55814e6/Carolla_600x600PNG.png',
        'rss_url' => 'http://theadamcarollashow.libsyn.com/rss'
        # 'comedian_ids' => comedian_ids
      }

    run(attributes)
    TheAdamCarollaShowParser.perform_in(4.hours)
  end
end
