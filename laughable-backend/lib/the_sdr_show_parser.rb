class TheSDRShowParser < LibsynParser
  def perform
    # comedian_ids = []
    # comedian_ids << Comedian.find_by(name: 'Christina Pazsitzky').id
    # comedian_ids << Comedian.find_by(name: 'Tom Segura').id

    attributes =
      {
        'title' => 'The SDR Show (Sex, Drugs, & Rock-n-Roll Show) w/ Big Jay Oakerson & Ralph Sutton',
        'website' => 'http://www.thesdrshow.com',
        'summary' => 'The SDR Show (Sex, Drugs, & Rock-n-Roll) is a one hour weekly podcast featuring comedian Big Jay Oakerson and radio host Ralph Sutton.  Each week they interview Porn Stars, Rock Stars, and more.   Big Jay Oakerson has been on the stand up circuit for over a decade.  Has had his own comedy special on comedy central, was the opening act for Korn on the Rockstar Energy Tour as well as many various TV shows and comedy tours.  Ralph Sutton has been the host of a nationally syndicated rock radio show for over a decade, has been a VJ on VH1-Classic as well as the host on various tv shows as well as of Shiprocked, M3 Rock Festival, and the Sturgis Motorcycle rally.',
        'image_url' => 'http://static.libsyn.com/p/assets/8/5/2/5/8525ffa46280e71c/SDRiTunes.jpg',
        'rss_url' => 'http://thesdrshow.libsyn.com/rss'
        # 'comedian_ids' => comedian_ids
      }

    run(attributes)
    TheSDRShowParser.perform_in(4.hours)
  end
end
