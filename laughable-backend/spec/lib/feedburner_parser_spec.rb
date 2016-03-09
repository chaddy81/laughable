# coding: utf-8
require 'rails_helper'
require 'spec_helper'
require 'feedburner_parser'

RSpec.describe FeedburnerParser do
  let(:rss_feed) { %Q(
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" media="screen" href="/~d/styles/rss2enclosuresfull.xsl"?><?xml-stylesheet type="text/css" media="screen" href="http://feeds.feedburner.com/~d/styles/itemcontent.css"?><rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:cc="http://web.resource.org/cc/" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:media="http://search.yahoo.com/mrss/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:feedburner="http://rssnamespace.org/feedburner/ext/1.0" version="2.0">
	<channel>

		<title>Judge John Hodgman</title>
		<pubDate>Wed, 03 Feb 2016 12:30:00 +0000</pubDate>
		<lastBuildDate>Thu, 04 Feb 2016 04:23:08 +0000</lastBuildDate>
		<generator>Libsyn WebEngine 2.0</generator>
		<link>http://www.maximumfun.org</link>
		<language>en</language>
		<copyright><![CDATA[2010]]></copyright>
		<docs>http://www.maximumfun.org</docs>
		<managingEditor>jesse@maximumfun.org (jesse@maximumfun.org)</managingEditor>
		<itunes:summary />
		<image>
			<url>http://static.libsyn.com/p/assets/a/9/3/a/a93a1d094735ef9c/judge-john-hodgman-square-mustache.jpg</url>
			<title>Judge John Hodgman</title>
			<link><![CDATA[http://www.maximumfun.org]]></link>
		</image>
		<itunes:author>John Hodgman and Maximum Fun</itunes:author>
		<itunes:keywords>complete,daily,expertise,hodgeman,hodgman,information,knowledge,mac,more,pc,show,world</itunes:keywords>
	<itunes:category text="Comedy" />
		<itunes:image href="http://static.libsyn.com/p/assets/a/9/3/a/a93a1d094735ef9c/judge-john-hodgman-square-mustache.jpg" />
		<itunes:explicit>no</itunes:explicit>
		<itunes:owner>
			<itunes:name><![CDATA[Jesse Thorn]]></itunes:name>
			<itunes:email>jesse@maximumfun.org</itunes:email>
		</itunes:owner>
		<description><![CDATA[John Hodgman's Today in the Past podcast is now The Judge John Hodgman Podcast.  Have your pressing issues decided by Famous Minor Television Personality John Hodgman, Certified Judge.  If you'd like John Hodgman to solve your pressing issue, simply email it, along with your phone number, to hodgman@maximumfun.org.  THAT IS ALL.]]></description>
		<itunes:subtitle />
				<atom10:link xmlns:atom10="http://www.w3.org/2005/Atom" rel="self" type="application/rss+xml" href="http://feeds.feedburner.com/todayinthepast" /><feedburner:info uri="todayinthepast" /><atom10:link xmlns:atom10="http://www.w3.org/2005/Atom" rel="hub" href="http://pubsubhubbub.appspot.com/" /><item>
			<title>Bros Before Globes</title>
			<pubDate>Wed, 03 Feb 2016 12:30:00 +0000</pubDate>
			<guid isPermaLink="false"><![CDATA[65fdf428dede698db079c8a3b035c213]]></guid>
			<link>http://feedproxy.google.com/~r/todayinthepast/~3/kCcVAN3xkOU/bros-before-globes</link>
			<itunes:image href="http://static.libsyn.com/p/assets/a/9/3/a/a93a1d094735ef9c/judge-john-hodgman-square-mustache.jpg" />
			<description>&lt;p&gt;Should a globe-trotting pal be forced to come home every once in a while?&lt;/p&gt;&lt;img src="http://feeds.feedburner.com/~r/todayinthepast/~4/kCcVAN3xkOU" height="1" width="1" alt=""/&gt;</description>
			<enclosure length="84231370" type="audio/mpeg" url="http://traffic.libsyn.com/jjhodgman/jjho_247.mp3" />
			<itunes:duration>58:23</itunes:duration>
			<itunes:explicit>no</itunes:explicit>
			<itunes:keywords />
			<itunes:subtitle><![CDATA[Should a globe-trotting pal be forced to come home every once in a while?]]></itunes:subtitle>
					<feedburner:origLink>http://jjhodgman.libsyn.com/bros-before-globes</feedburner:origLink></item>
		<item>
			<title>Miami Memories</title>
			<pubDate>Fri, 29 Jan 2016 02:04:44 +0000</pubDate>
			<guid isPermaLink="false"><![CDATA[9afb173224ed193bf81d45105dd47ec7]]></guid>
			<link>http://feedproxy.google.com/~r/todayinthepast/~3/9dH0lg3P5GM/miami-memories</link>
			<itunes:image href="http://static.libsyn.com/p/assets/a/9/3/a/a93a1d094735ef9c/judge-john-hodgman-square-mustache.jpg" />
			<description>&lt;p&gt;Judge Hodgman and Bailiff Jesse address airplane etiquette, the importance of Hamilton, swear words and more! There's no explicit content in this one, but you may not want kids listening to it all the same.&lt;/p&gt;&lt;img src="http://feeds.feedburner.com/~r/todayinthepast/~4/9dH0lg3P5GM" height="1" width="1" alt=""/&gt;</description>
			<enclosure length="49982546" type="audio/mpeg" url="http://traffic.libsyn.com/jjhodgman/jjho_246.mp3" />
			<itunes:duration>51:54</itunes:duration>
			<itunes:explicit>no</itunes:explicit>
			<itunes:keywords />
			<itunes:subtitle><![CDATA[Judge Hodgman and Bailiff Jesse address airplane etiquette, the importance of Hamilton, swear words and more! There's no explicit content in this one, but you may not want kids listening to it all the same.]]></itunes:subtitle>
					<feedburner:origLink>http://jjhodgman.libsyn.com/miami-memories</feedburner:origLink></item>
	</channel>
</rss>
) }

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

      FeedburnerParser.new.run(attributes)

      expect(Podcastepisode.count).to eq episode_count + 2
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

      FeedburnerParser.new.run(attributes)
      expect(Podcast.count).to eq podcast_count + 1
      expect(Podcastepisode.count).to eq episode_count + 2
    end
  end
  describe 'parse_feed' do
    it 'should return nil' do
      parser = FeedburnerParser.new
      expect(parser.parse_feed).to eq nil
    end
    it 'should return a Feedjira::Feed::ITunesRSS object' do
      parser = FeedburnerParser.new
      feed = parser.parse_feed(rss_feed)
      expect(feed.entries.count).to eq 2
    end
  end

  describe 'create_podcast' do
    it 'should create a new podcast object' do
      parser = FeedburnerParser.new
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
      parser = FeedburnerParser.new
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
      parser = FeedburnerParser.new
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
