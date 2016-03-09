class GuysWeFd < SoundcloudParser
  def perform
    # comedian_ids = []
    # comedian_ids << Comedian.find_by(name: 'Robert Kelly').id
    attributes =
      {
        'title' => 'Guys We F****d',
        'summary' => "Welcome to GUYS WE F****D: THE ANTI SLUT-SHAMING PODCAST. They spread their legs, now they're spreading the word that women should be able to have sex with WHOEVER they want WHENEVER they want and not be ashamed or called sluts or whores. Welcome to a new revolution. Each week, Corinne Fisher and Krystyna Hutchinson (together known as the comedy duo Sorry About Last Night) interview a gentleman they slept with. Some they made love to, some they had sex with a few times and some they f****d in a hotel bathroom...er, what? Corinne and Krystyna want to make the world a more sex-positive place...one candid story of intercourse at a time.",
        'image_url' => 'http://i1.sndcdn.com/avatars-000157639267-4os6db-original.jpg',
        'rss_url' => 'http://feeds.soundcloud.com/users/soundcloud:users:68891950/sounds.rss'
        # 'comedian_ids' => comedian_ids
      }

    run(attributes)
    GuysWeFd.perform_in(4.hours)
  end
end
