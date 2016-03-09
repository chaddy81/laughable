class FitzdogRadioParser < LibsynParser
  def perform
    # comedian_ids = []
    # comedian_ids << Comedian.find_by(name: 'Moshe Kasher').id
    # comedian_ids << Comedian.find_by(name: 'Neal Brennan').id

    attributes =
      {
        'title' => 'Fitzdog Radio',
        'website' => 'http://gregfitz.libsyn.com',
        'summary' => 'Fitzdog Radio! A place where Greg can continue his Sirius / XM Show on Howard 101, and give you more interview time with the guest, and more funny.',
        'image_url' => 'http://static.libsyn.com/p/assets/c/a/2/0/ca20a50bab0ab60a/FitzDog-Podcast-Art300.jpg',
        'rss_url' => 'http://gregfitz.libsyn.com/rss'
        # 'comedian_ids' => comedian_ids
      }

    run(attributes)
    FitzdogRadioParser.perform_in(4.hours)
  end
end
