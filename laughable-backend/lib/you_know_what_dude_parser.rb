class YouKnowWhatDudeParser < LibsynParser
  def perform
    # comedian_ids = []
    # comedian_ids << Comedian.find_by(name: 'Robert Kelly').id

    attributes =
      {
        'title' => 'You Know What Dude!',
        'website' => 'http://robertkelly.libsyn.com',
        'summary' => 'Did you ever go to a comedy club and see the comics at the back table laughing hysterically? Did you ever wish you could hear what they were talking about? Hosted by Robert Kelly, The \'You Know What Dude\' podcast provides you a seat at that table as comedians new and old try to one up and out wit each other.',
        'image_url' => 'http://static.libsyn.com/p/assets/9/9/a/2/99a25287ab19cee7/ykwd_2014_1400.jpg',
        'rss_url' => 'http://robertkelly.libsyn.com/rss'
        # 'comedian_ids' => comedian_ids
      }

    run(attributes)
    YouKnowWhatDudeParser.perform_in(4.hours)
  end
end
