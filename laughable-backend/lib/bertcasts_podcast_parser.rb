class BertcastsPodcastParser < LibsynParser
  def perform
    # comedian_ids = []
    # comedian_ids << Comedian.find_by(name: 'Christina Pazsitzky').id
    # comedian_ids << Comedian.find_by(name: 'Tom Segura').id

    attributes =
      {
        'title' => 'Bertcast\'s podcast',
        'website' => 'http://bertcast.libsyn.com',
        'summary' => 'Comic and man of the world Bert Kreischer shares his wisdom and life with you.',
        'image_url' => 'http://static.libsyn.com/p/assets/a/0/f/b/a0fb9b3928abf3f9/1400x1400Bertcast2.jpg',
        'rss_url' => 'http://bertcast.libsyn.com/rss'
        # 'comedian_ids' => comedian_ids
      }

    run(attributes)
    BertcastsPodcastParser.perform_in(4.hours)
  end
end
