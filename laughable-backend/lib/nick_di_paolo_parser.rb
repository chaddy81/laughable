class NickDiPaoloParser < LibsynParser
  def perform
    # comedian_ids = []
    # comedian_ids << Comedian.find_by(name: 'Nick Di Paolo').id

    attributes =
      {
        'title' => 'Nick Di Paolo',
        'summary' => 'Nick Di Paolo is one of the most authentic voices in the stand up world today. He\'s referred to as a comic\'s comic because there are no facades, no act. Nick has had three half-hour specials on Comedy Central, a one-hour critically acclaimed special on ShowTime entitled \'Raw Nerve.\' His latest release is the hysterical \'Another Senseless Killing.\' Nick now brings his raw and honest approach to podcasting on The RiotCast Network. Uncensored and unapologetic.',
        'image_url' => 'http://static.libsyn.com/p/assets/b/c/e/a/bcea518f89e74bbb/Nick_DiPaolo-1400.jpg',
        'rss_url' => 'http://nickdipaolo.libsyn.com/rss'
        # 'comedian_ids' => comedian_ids
      }

    run(attributes)
    NickDiPaoloParser.perform_in(4.hours)
  end
end
