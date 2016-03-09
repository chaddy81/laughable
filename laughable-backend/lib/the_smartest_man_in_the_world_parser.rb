class TheSmartestManInTheWorldParser < LibsynParser
  def perform
    # comedian_ids = []
    # comedian_ids << Comedian.find_by(name: 'Moshe Kasher').id
    # comedian_ids << Comedian.find_by(name: 'Neal Brennan').id

    attributes =
      {
        'title' => 'The Smartest Man in the World',
        'website' => 'http://smartest.libsyn.com/',
        'summary' => 'Comedian Greg Proops is the Smartest Man in the World.',
        'image_url' => 'http://static.libsyn.com/p/assets/9/a/7/2/9a72182049b9903b/SMITW_new_logo_libsyn.jpg',
        'rss_url' => 'http://smartest.libsyn.com/rss'
        # 'comedian_ids' => comedian_ids
      }

    run(attributes)
    TheSmartestManInTheWorldParser.perform_in(4.hours)
  end
end
