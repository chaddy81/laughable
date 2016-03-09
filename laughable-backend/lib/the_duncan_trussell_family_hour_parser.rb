class TheDuncanTrussellFamilyHourParser < LibsynParser
  def perform
    # comedian_ids = []
    # comedian_ids << Comedian.find_by(name: 'DuncanTrussell').id

    attributes =
      {
        'title' => 'The Duncan Trussell Family Hour',
        'website' => 'http://www.duncantrussell.com',
        'summary' => 'A weekly salon-style supershow, where comedian Duncan Trussell and guests explore the outer reaches of the multiverse.',
        'image_url' => 'http://static.libsyn.com/p/assets/5/3/7/1/53713dde67c77a26/artwork_duncan_trussell_family_hour.jpg',
        'rss_url' => 'http://lavenderhour.libsyn.com/rss'
        # 'comedian_ids' => comedian_ids
      }

    run(attributes)
    TheDuncanTrussellFamilyHourParser.perform_in(4.hours)
  end
end
