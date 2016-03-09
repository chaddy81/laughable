class ContentSubmissionProfileCreation
  include Sidekiq::Worker

  def perform(submission_id)
    cmscontent = Cmscontent.find(submission_id)

    return unless cmscontent.present?

    entry = cmscontent.entry
    p_info = entry['personal_info']
    f_name = entry['first_name']
    l_name = entry['last_name']
    if Comedian.find_by(first_name: f_name, last_name: l_name).present?
      comedian = Comedian.find_by(first_name: f_name, last_name: l_name)

      track_hash = entry['track_list']
      track_hash.keys.each do |key|
        t = track_hash[key]
        t_name = t['name'].split('.mp3')[0]
        track = Track.new
        track.author = "#{comedian.first_name} #{comedian.last_name}"
        track.title = t_name
        track.comedian_id = comedian.id
        track.high_stream_url = "/audio/#{t_name}high.mp4"
        track.medium_stream_url = "/audio/#{t_name}medium.mp4"
        track.low_stream_url = "/audio/#{t_name}low.mp4"
        track.staging_only = true
        track.save!
      end
    else
      comedian = Comedian.new
      comedian.first_name = p_info['first_name']
      comedian.last_name = p_info['last_name']
      comedian.biography = p_info['biography']
      comedian.website = p_info['website']
      comedian.twitter_name = clean_name(p_info['twitter'])
      comedian.facebook_name = clean_fb_name(p_info['facebook'])
      comedian.instagram_name = clean_name(p_info['instagram'])
      comedian.profile_picture = "/images/#{p_info['photo_url']}"
      comedian.staging_only = true
      comedian.save!

      track_hash = entry['track_list']
      track_hash.keys.each do |key|
        t = track_hash[key]
        t_name = t['name'].split('.mp3')[0]
        track = Track.new
        track.author = "#{comedian.first_name} #{comedian.last_name}"
        track.title = t_name
        track.comedian_id = comedian.id
        track.high_stream_url = "/audio/#{t_name}high.mp4"
        track.medium_stream_url = "/audio/#{t_name}medium.mp4"
        track.low_stream_url = "/audio/#{t_name}low.mp4"
        track.staging_only = true
        track.save!
      end
    end
  end

  private

  def clean_fb_name(name)
    return if name.nil? or name.empty?
    name.split("facebook.com/").last.split('/').first
  end

  def clean_name(name)
    return if name.nil? or name.empty?
    name.split(//).drop(1).join if name.split(//)[0] == '@'
  end
end
