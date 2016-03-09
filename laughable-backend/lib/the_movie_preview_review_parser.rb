class TheMoviePreviewReviewParser < LibsynParser
  def perform
    # comedian_ids = []
    # comedian_ids << Comedian.find_by(name: 'Christina Pazsitzky').id
    # comedian_ids << Comedian.find_by(name: 'Tom Segura').id

    attributes =
      {
        'title' => 'The Movie Preview Review with Kevin Bartini',
        'website' => 'http://themoviepreviewreviewpodcast.libsyn.com/podcast',
        'summary' => 'Comedian Kevin Bartini and friends review movies after only watching their previews. An hilarious conversation about movies with some of today\'s best comedy stars.',
        'image_url' => 'http://static.libsyn.com/p/assets/6/2/6/4/6264dd1ccb5485fa/MPR_Logo_1400x1400.jpg',
        'rss_url' => 'http://themoviepreviewreviewpodcast.libsyn.com/rss'
        # 'comedian_ids' => comedian_ids
      }

    run(attributes)
    TheMoviePreviewReviewParser.perform_in(4.hours)
  end
end
