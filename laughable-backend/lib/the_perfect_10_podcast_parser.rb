class ThePerfect10PodcastParser < LibsynParser
  def perform
    # comedian_ids = []
    # comedian_ids << Comedian.find_by(name: 'Christina Pazsitzky').id
    # comedian_ids << Comedian.find_by(name: 'Tom Segura').id

    attributes =
      {
        'title' => 'The Perfect 10 Podcast w/ Ralphie May & Lahna Turner',
        'website' => 'http://allthingscomedy.com/channels/66/perfect-10',
        'summary' => 'Husband and wife, as well as comedians Ralphie May and Lahna Turner team up in "The Perfect 10," a podcast that takes a look at their personal and professional lives, and features segments from the crazy characters they\'ve encountered on their journey together. Both are internationally touring comic sensations; May, of "Last Comic Standing," has had four Comedy Central specials, and Turner has been showcased on National Lampoon\'s Top 40 Comedy Countdown and Sirius Satellite Radio. Check them out on www.Perfect10Pod.com.',
        'image_url' => 'http://static.libsyn.com/p/assets/e/d/f/7/edf75e2a0aff1414/Itunespic.jpg',
        'rss_url' => 'http://perfect10.libsyn.com/rss'
        # 'comedian_ids' => comedian_ids
      }

    run(attributes)
    ThePerfect10PodcastParser.perform_in(4.hours)
  end
end
