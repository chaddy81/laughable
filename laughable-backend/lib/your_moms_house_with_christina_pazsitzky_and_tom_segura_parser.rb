class YourMomsHousewithChristinaPazsitzkyandTomSeguraParser < LibsynParser
  def perform
    comedian_ids = []
    comedian_ids << Comedian.find_by(name: 'Tom Segura').id

    attributes =
      {
        'title' => 'Your Mom\'s House with Christina Pazsitzky and Tom Segura',
        'website' => 'http://yourmomshousepodcast.libsyn.com/',
        'summary' => 'Christina Pazsitzky and Tom Segura are comedians who are also married. They are the Mommies and they welcome you to join them. Dental updates! Dudes! Stories! Wiping!',
        'image_url' => 'http://static.libsyn.com/p/assets/b/5/7/0/b57088946406a376/YMH_cover2_copy.jpg',
        'rss_url' => 'http://yourmomshousepodcast.libsyn.com/rss',
        'comedian_ids' => comedian_ids
      }

    run(attributes)
    YourMomsHousewithChristinaPazsitzkyandTomSeguraParser.perform_in(4.hours)
  end
end
