require 'rails_helper'
require 'spec_helper'
require 'libsyn_parser'

RSpec.describe LibsynParser do
  let(:rss_feed) { %Q(<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:cc="http://web.resource.org/cc/" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:media="http://search.yahoo.com/mrss/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
	<channel>
		<atom:link href="http://youmadeitweird.libsyn.com/rss" rel="self" type="application/rss+xml"/>
		<title>You Made It Weird with Pete Holmes</title>
		<pubDate>Wed, 27 Jan 2016 08:00:00 +0000</pubDate>
		<lastBuildDate>Wed, 27 Jan 2016 08:04:24 +0000</lastBuildDate>
		<generator>Libsyn WebEngine 2.0</generator>
		<link>http://youmadeitweird.libsyn.com</link>
		<language>en</language>
		<copyright><![CDATA[2011 Nerdist Industries]]></copyright>
		<docs>http://youmadeitweird.libsyn.com</docs>
		<managingEditor>katie@nerdist.com (katie@nerdist.com)</managingEditor>
		<itunes:summary><![CDATA[Everybody has secret weirdness, Pete Holmes gets comedians to share theirs.]]></itunes:summary>
		<image>
			<url>http://static.libsyn.com/p/assets/c/9/6/4/c96469ee482d87aa/YMIW_logo.jpg</url>
			<title>You Made It Weird with Pete Holmes</title>
			<link><![CDATA[http://youmadeitweird.libsyn.com]]></link>
		</image>
		<itunes:author>Nerdist Industries</itunes:author>
		<itunes:keywords>comedy,peteholmes</itunes:keywords>
	<itunes:category text="Comedy"/>
	<itunes:category text="Society &amp; Culture"/>
	<itunes:category text="Health">
		<itunes:category text="Self-Help"/>
	</itunes:category>
		<itunes:image href="http://static.libsyn.com/p/assets/c/9/6/4/c96469ee482d87aa/YMIW_logo.jpg" />
		<itunes:explicit>yes</itunes:explicit>
		<itunes:owner>
			<itunes:name><![CDATA[Nerdist Industries]]></itunes:name>
			<itunes:email>podcast@nerdist.com</itunes:email>
		</itunes:owner>
		<description><![CDATA[Everybody has secret weirdness, Pete Holmes gets comedians to share theirs.]]></description>
		<itunes:subtitle><![CDATA[]]></itunes:subtitle>
				<item>
			<title>Ian Karmel Returns</title>
			<pubDate>Wed, 27 Jan 2016 08:00:00 +0000</pubDate>
			<guid isPermaLink="false"><![CDATA[b34816ab3f347a58883d6794d136a7c1]]></guid>
			<link><![CDATA[http://youmadeitweird.libsyn.com/ian-karmel-returns]]></link>
			<itunes:image href="http://static.libsyn.com/p/assets/d/0/2/d/d02d3348162cc28a/YMIW_logo.jpg" />
			<description><![CDATA[<p>Ian Karmel (comedian! Late Late Show with James Corden!) makes it weird again!</p>]]></description>
			<enclosure length="59252821" type="audio/mpeg" url="http://traffic.libsyn.com/youmadeitweird/YMIW302_Ian_Karmel_Returns.mp3" />
			<itunes:duration>02:02:25</itunes:duration>
			<itunes:explicit>yes</itunes:explicit>
			<itunes:keywords />
			<itunes:subtitle><![CDATA[Ian Karmel (comedian! Late Late Show with James Corden!) makes it weird again!]]></itunes:subtitle>
					</item>
		<item>
			<title>Best Of YMIW!</title>
			<pubDate>Fri, 22 Jan 2016 08:00:00 +0000</pubDate>
			<guid isPermaLink="false"><![CDATA[3e0316e00a3ded2f5d2437946d4479a4]]></guid>
			<link><![CDATA[http://youmadeitweird.libsyn.com/best-of-ymiw]]></link>
			<itunes:image href="http://static.libsyn.com/p/assets/d/c/d/d/dcdd62e667f4305e/YMIW_logo.jpg" />
			<description><![CDATA[<p>A compilation of fan-favorite bits, riffs and jokes from across the 300 episodes! List of riffs, in order:</p>
<p>Not Feelin' It with Patrick Walsh</p>
<p>Matt Damon Story with Ben Schwartz</p>
<p>Is It A Horse? with Jenny Slate</p>
<p>Workin' Today with Johnny Pemberton</p>
<p>My Ankles with Adam Pally</p>
<p>Racist Stephen Hawkings with Moshe Kasher</p>
<p>Hurt Linda with Ryan Sickler</p>
<p>Fake Christmas with Nick Swardson</p>
<p>Peanu Keys with Harris Wittels</p>
<p>Stripper Story with Patrick Walsh</p>
<p>Miss Ya Mitch with Chelsea Peretti</p>
<p>Blink 182 with Whitmer Thomas</p>
<p>Shitting in the Rain with Nate Fernald</p>
<p>Kumail Impressions with Thomas Middleditch</p>
<p>Medium Soup with Moshe Kasher</p>
<p>Hey Buddy with Josh Ruben</p>
<p>500 weeks with Chris Thayer</p>
<p>Singing with Bert Kreischer</p>]]></description>
			<enclosure length="43297436" type="audio/mpeg" url="http://traffic.libsyn.com/youmadeitweird/YMIW301_Best_Of_YMIW.mp3" />
			<itunes:duration>01:29:10</itunes:duration>
			<itunes:explicit>yes</itunes:explicit>
			<itunes:keywords />
			<itunes:subtitle><![CDATA[A compilation of fan-favorite bits, riffs and jokes from across the 300 episodes! List of riffs, in order:
Not Feelin' It with Patrick Walsh
Matt Damon Story with Ben Schwartz
Is It A Horse? with Jenny Slate
Workin' Today with Johnny Pemberton
My...]]></itunes:subtitle>
					</item>
		<item>
			<title>The 300th Episode!</title>
			<pubDate>Wed, 20 Jan 2016 08:00:00 +0000</pubDate>
			<guid isPermaLink="false"><![CDATA[4e9ac884d3d696a4446b7676b40a60f7]]></guid>
			<link><![CDATA[http://youmadeitweird.libsyn.com/the-300th-episode]]></link>
			<itunes:image href="http://static.libsyn.com/p/assets/f/9/8/f/f98fea93882011fb/YMIW_logo.jpg" />
			<description><![CDATA[<p>It's the 300th episode! Pete, Valerie and Brent Sullivan enjoy some drinks and answer your questions!</p>]]></description>
			<enclosure length="68679887" type="audio/mpeg" url="http://traffic.libsyn.com/youmadeitweird/YMIW300_The_300th_Episode.mp3" />
			<itunes:duration>02:22:03</itunes:duration>
			<itunes:explicit>yes</itunes:explicit>
			<itunes:keywords />
			<itunes:subtitle><![CDATA[It's the 300th episode! Pete, Valerie and Brent Sullivan enjoy some drinks and answer your questions!]]></itunes:subtitle>
					</item>
		<item>
			<title>Parvati Markus</title>
			<pubDate>Fri, 15 Jan 2016 08:00:00 +0000</pubDate>
			<guid isPermaLink="false"><![CDATA[a316cc25f2372e199336a5fc20550ed0]]></guid>
			<link><![CDATA[http://youmadeitweird.libsyn.com/parvati-markus]]></link>
			<itunes:image href="http://static.libsyn.com/p/assets/8/1/f/4/81f47b550b921396/YMIW_logo.jpg" />
			<description><![CDATA[<p>Parvati Markus (author of <em>Love Everyone</em>) makes it weird!</p>]]></description>
			<enclosure length="44095738" type="audio/mpeg" url="http://traffic.libsyn.com/youmadeitweird/YMIW299.5_Parvati_Markus.mp3" />
			<itunes:duration>01:30:50</itunes:duration>
			<itunes:explicit>yes</itunes:explicit>
			<itunes:keywords />
			<itunes:subtitle><![CDATA[Parvati Markus (author of Love Everyone) makes it weird!]]></itunes:subtitle>
</item>
</channel>
</rss>) }

  describe 'run' do
    it 'should find an already existing podcast and add episodes for it' do
      comedian1 = Comedian.create
      comedian2 = Comedian.create
      attributes =
        {
          'title' => 'title',
          'summary' => 'summary',
          'image_url' => 'image_url',
          'rss_url' => rss_feed,
          'comedian_ids' => [comedian1.id, comedian2.id]
        }

      podcast = Podcast.create(attributes)
      Podcastepisode.create(podcast_id: podcast.id)
      podcast_count = Podcast.count
      episode_count = Podcastepisode.count

      LibsynParser.new.run(attributes)

      expect(Podcastepisode.count).to eq episode_count + 4
      expect(Podcast.count).to eq podcast_count
    end
    it 'should create a new podcast and create episodes for it' do
      comedian1 = Comedian.create
      comedian2 = Comedian.create

      attributes =
        {
          'title' => 'title',
          'website' => 'website',
          'summary' => 'summary',
          'image_url' => 'image_url',
          'rss_url' => rss_feed,
          'comedian_ids' => [comedian1.id, comedian2.id]
        }

      podcast_count = Podcast.count
      episode_count = Podcastepisode.count

      LibsynParser.new.run(attributes)
      expect(Podcast.count).to eq podcast_count + 1
      expect(Podcastepisode.count).to eq episode_count + 4
    end
  end

  describe 'parse_feed' do
    it 'should return nil' do
      parser = LibsynParser.new
      expect(parser.parse_feed).to eq nil
    end
    it 'should return a Feedjira::Feed::ITunesRSS object' do
      parser = LibsynParser.new
      feed = parser.parse_feed(rss_feed)
      expect(feed.entries.count).to eq 4
    end
  end

  describe 'create_podcast' do
    it 'should create a new podcast object' do
      parser = LibsynParser.new
      old_count = Podcast.count
      attributes =
        {
          title: 'title',
          website: 'website',
          summary: 'summary',
          image_url: 'image_url',
          rss_url: 'rss_url',
          comedian_ids: [1, 2]
        }

      parser.create_podcast(attributes)
      expect(Podcast.count).to eq old_count + 1
    end
  end
  describe 'get_podcast' do
    it 'should return an already existing podcast object' do
      parser = LibsynParser.new
      existing = Podcast.create(title: 'title', rss_url: 'rss_url')
      attributes =
        {
          'title' => 'title',
          'website' => 'website',
          'summary' => 'summary',
          'image_url' => 'image_url',
          'rss_url' => 'rss_url',
          'comedian_ids' => [1, 2]
        }

      response = parser.get_podcast(attributes)

      expect(response).to eq existing
    end
    it 'should create a new podcast and return it' do
      parser = LibsynParser.new
      existing = Podcast.create(title: 'old_title', rss_url: 'rss_url')
      attributes =
        {
          'title' => 'title',
          'summary' => 'summary',
          'image_url' => 'image_url',
          'rss_url' => 'rss_url',
          'comedian_ids' => [1, 2]
        }

      response = parser.get_podcast(attributes)
      expect(response).to_not eq existing
      expect(response.title).to eq 'title'
      expect(response.summary).to eq 'summary'
      expect(response.image_url).to eq 'image_url'
      expect(response.rss_url).to eq 'rss_url'
      expect(response.comedian_ids).to eq [1, 2]
    end
  end
end
