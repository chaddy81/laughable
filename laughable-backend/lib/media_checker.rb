class MediaChecker
  include Sidekiq::Worker
  def perform
    check_tracks
    check_profile_pictures
    MediaChecker.perform_in(1.day)
    AlertHubot.perform_in(3.minutes)
  end

  def check_profile_pictures
    comedian_ids = Comedian.pluck(:id)
    comedian_ids.each { |comedian_id| ProfileChecker.perform_async(comedian_id) }
  end

  def check_tracks
    track_ids = Track.pluck(:id)
    track_ids.each { |track_id| TrackChecker.perform_async(track_id) }
  end
end
