class CashingInWithTjMillerParser < LibsynParser
  def perform
    # comedian_ids = []
    # comedian_ids << Comedian.find_by(name: 'Christina Pazsitzky').id
    # comedian_ids << Comedian.find_by(name: 'Tom Segura').id

    attributes =
      {
        'title' => 'Cashing in with T.J. Miller',
        'website' => 'http://cashinginwithtjmiller.libsyn.com/',
        'summary' => 'Host Cash Levy can\'t get any other guests, although he\'d like to.  Listen to thought provoking nonsense as Cash interviews T.J. Miller over and over again.  Aren\'t you tired of everybody interviewing more than one person? It\'s the podcast no one has heard of and everyone is talking about.  Philosophy, unsolicited advice, answers to questions you didn\'t have... They pistol whip the worlds mysteries into submission- saving lives one podcast at a time, and ruining a life every tenth.  Just listen... you need to hear this.',
        'image_url' => 'http://static.libsyn.com/p/assets/d/f/0/0/df00832f89c768c6/CTJ_logo.jpg',
        'rss_url' => 'http://cashinginwithtjmiller.libsyn.com/rss'
        # 'comedian_ids' => comedian_ids
      }

    run(attributes)
    CashingInWithTjMillerParser.perform_in(4.hours)
  end
end
