# coding: utf-8
require 'rails_helper'
require 'spec_helper'
require 'libsyn_parser'

RSpec.describe SoundcloudParser do
  let(:rss_feed) { %Q(<?xml version="1.0" encoding="UTF-8"?><rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" version="2.0">
  <channel>
    <atom:link href="http://feeds.soundcloud.com/users/soundcloud:users:197681131/sounds.rss" rel="self" type="application/rss+xml"/>
    <atom:link href="http://feeds.soundcloud.com/users/soundcloud:users:197681131/sounds.rss?before=240564260" rel="next" type="application/rss+xml"/>
    <title>Not Safe Podcast with Nikki Glaser</title>
    <link>http://soundcloud.com/not-safe-podcast</link>
    <pubDate>Fri, 05 Feb 2016 16:45:09 +0000</pubDate>
    <lastBuildDate>Fri, 05 Feb 2016 16:45:09 +0000</lastBuildDate>
    <ttl>60</ttl>
    <language>en</language>
    <copyright>All rights reserved</copyright>
    <webMaster>feeds@soundcloud.com (SoundCloud Feeds)</webMaster>
    <description>Nikki Glaser, host of Comedy Central's Not Safe w/ Nikki Glaser is joined by co-host Dan St. Germain to discuss sex news and personal stories about dating and relationships. </description>
    <itunes:subtitle>Nikki Glaser, host of Comedy Central's Not Safe w…</itunes:subtitle>
    <itunes:owner>
      <itunes:name>Not Safe Podcast</itunes:name>
      <itunes:email>feeds@soundcloud.com</itunes:email>
    </itunes:owner>
    <itunes:author>Comedy Central</itunes:author>
    <itunes:explicit>yes</itunes:explicit>
    <itunes:image href="http://i1.sndcdn.com/avatars-000197587545-wk1i55-original.jpg"/>
    <image>
      <url>http://i1.sndcdn.com/avatars-000197587545-wk1i55-original.jpg</url>
      <title>Not Safe Podcast</title>
      <link>http://soundcloud.com/not-safe-podcast</link>
    </image>
    <itunes:category text="Comedy"/>
    <item>
      <guid isPermaLink="false">tag:soundcloud,2010:tracks/245268804</guid>
      <title>Episode 05: Use Protection</title>
      <pubDate>Wed, 03 Feb 2016 18:01:10 +0000</pubDate>
      <link>https://soundcloud.com/not-safe-podcast/episode-05-use-protection</link>
      <itunes:duration>00:47:03</itunes:duration>
      <itunes:author>Comedy Central</itunes:author>
      <itunes:explicit>yes</itunes:explicit>
      <itunes:summary>This week, Dan's dad gets hit by a car, Nikki talks about how flying to Thailand is not the best time to meet your boyfriend and how you should just ignore what anyone says on the Internet.</itunes:summary>
      <itunes:subtitle>This week, Dan's dad gets hit by a car, Nikki tal…</itunes:subtitle>
      <description>This week, Dan's dad gets hit by a car, Nikki talks about how flying to Thailand is not the best time to meet your boyfriend and how you should just ignore what anyone says on the Internet.</description>
      <enclosure type="audio/mpeg" url="http://feeds.soundcloud.com/stream/245268804-not-safe-podcast-episode-05-use-protection.mp3" length="56931819"/>
      <itunes:image href="http://i1.sndcdn.com/artworks-000145740887-zc3d4q-original.jpg"/>
    </item>
    <item>
      <guid isPermaLink="false">tag:soundcloud,2010:tracks/244048508</guid>
      <title>Episode 04: Anal Around The World</title>
      <pubDate>Wed, 27 Jan 2016 14:31:40 +0000</pubDate>
      <link>https://soundcloud.com/not-safe-podcast/episode-04-anal-around-the-world</link>
      <itunes:duration>00:31:10</itunes:duration>
      <itunes:author>Comedy Central</itunes:author>
      <itunes:explicit>yes</itunes:explicit>
      <itunes:summary>Nikki figures out who in the studio has done anal, Dan gets beef for spilling soup on his crotch and we figure the only way involving your dad in sex can be hot.</itunes:summary>
      <itunes:subtitle>Nikki figures out who in the studio has done anal…</itunes:subtitle>
      <description>Nikki figures out who in the studio has done anal, Dan gets beef for spilling soup on his crotch and we figure the only way involving your dad in sex can be hot.</description>
      <enclosure type="audio/mpeg" url="http://feeds.soundcloud.com/stream/244048508-not-safe-podcast-episode-04-anal-around-the-world.mp3" length="37871057"/>
      <itunes:image href="http://i1.sndcdn.com/artworks-000144796552-3shjl6-original.jpg"/>
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

      SoundcloudParser.new.run(attributes)

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

      SoundcloudParser.new.run(attributes)
      expect(Podcast.count).to eq podcast_count + 1
      expect(Podcastepisode.count).to eq episode_count + 2
    end
  end

  describe 'parse_feed' do
    it 'should return nil' do
      parser = SoundcloudParser.new
      expect(parser.parse_feed).to eq nil
    end
    it 'should return a Feedjira::Feed::ITunesRSS object' do
      parser = SoundcloudParser.new
      feed = parser.parse_feed(rss_feed)
      expect(feed.entries.count).to eq 2
    end
  end

  describe 'create_podcast' do
    it 'should create a new podcast object' do
      parser = SoundcloudParser.new
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
      parser = SoundcloudParser.new
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
      parser = SoundcloudParser.new
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
