class ReasonableDoubtParser < FeedburnerParser
    def perform
        #        comedian_ids = []
        #        comedian_ids << Comedian.find_by(name: 'Chelsea Peretti').id
        
        attributes =
        {
            'title' => 'Reasonable Doubt',
            'summary' => 'Comedian Adam Carolla is joined by criminal defense attorney Mark Geragos for a no holds barred conversation about current events, pop-culture and their own personal lives. Along with occasional guests the guys will also take listener phone calls and answer your questions.',
            'image_url' => 'https://art19-production.s3-us-west-1.amazonaws.com/images/b4/a9/88/02/b4a98802-67fb-4215-97a5-efc5d132d5f3/15b329286e38a0df7782ff31c9e92e23647c0821cd34db3fa0b18c956c75838abd16e60768bae3b843458d736f77f99350ed90a7b88620f456f86c9bfee140cb.jpeg',
            'rss_url' => 'http://ace.noxsolutions.com/images/podcast/ReasonableDoubt_1400x1400.jpg',
            #            'comedian_ids' => comedian_ids
        }
        
        run(attributes)
        ReasonableDoubtParser.perform_in(4.hours)
    end
end