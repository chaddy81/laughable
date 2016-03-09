class AriShaffirsSkepticTankParser < LibsynParser
  def perform
    comedian_ids = []
    comedian_ids << Comedian.find_by(first_name: 'Ari', last_name: 'Shaffir').id
    # comedian_ids << Comedian.find_by(name: 'Neal Brennan').id

    attributes =
      {
        'title' => 'Ari Shaffir\'s Skeptic Tank',
        'website' => 'http://shaffir1.libsyn.com/',
        'summary' => 'A comedy podcast to help better understand humanity and also to make fart jokes.',
        'image_url' => 'http://static.libsyn.com/p/assets/b/4/2/5/b4254b9d8fe44416/SkepticTank_cover4.jpg',
        'rss_url' => 'http://shaffir1.libsyn.com/rss',
        # 'comedian_ids' => comedian_ids
      }

    run(attributes)
    AriShaffirsSkepticTankParser.perform_in(4.hours)
  end
end
