class DougLovesMoviesParser < FeedburnerParser
  def perform
    # comedian_ids = []
    # comedian_ids << Comedian.find_by(name: 'Moshe Kasher').id
    # comedian_ids << Comedian.find_by(name: 'Neal Brennan').id

    attributes =
      {
        'title' => 'Doug Loves Movies',
        'summary' => 'Comedian Doug Benson (Super High Me, Last Comic Standing) invites his friends to sit down and discuss his first love: movies!',
        'image_url' => 'https://art19-production.s3-us-west-1.amazonaws.com/images/82/2f/79/e8/822f79e8-722d-4a6b-8647-8cc9741e87a9/f933e361a2ab293aa85d74f63a4ea343522012cae57c6efa04c518b09d5ad28201c3312b452e93b09b6e349f33b211553dedcf0b7ab4da2702d3680700b416ec.jpeg',
        'rss_url' => 'http://feeds.feedburner.com/DougLovesMovies',
        # 'comedian_ids' => comedian_ids
      }

    run(attributes)
    DougLovesMoviesParser.perform_in(4.hours)
  end
end
