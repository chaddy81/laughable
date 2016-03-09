class TheToddGlassShowParser < LibsynParser
  def perform
    # comedian_ids = []
    # comedian_ids << Comedian.find_by(name: 'Todd Glass').id

    attributes =
      {
        'title' => 'The Todd Glass Show',
        'website' => 'http://toddglassshow.libsyn.com',
        'summary' => 'Todd Glass and friends talk about stuff.',
        'image_url' => 'http://static.libsyn.com/p/assets/5/6/1/0/5610162170129e01/toddlogo.jpg',
        'rss_url' => 'http://toddglassshow.libsyn.com/rss'
        # 'comedian_ids' => comedian_ids
      }

    run(attributes)
    TheToddGlassShowParser.perform_in(4.hours)
  end
end
