class PredictionioSendEvent
  include Sidekiq::Worker

  def perform
    skipped_tracks = MixpanelEvent.where(event: 'Skipped Track')
    skipped_tracks.each do |track|
      comedian_name = track.payload['properties']['Comedian']
      track_title = track.payload['properties']['Track']
      skip_time = track.payload['properties']['Skip Time']
      t = Track.find_by(title: track_title)
      c = Comedian.find_by(id: t.comedian_id)
      full_name = "#{c.first_name} #{c.last_name}"
      if full_name == comedian_name
        $pio_up_next.create_event(
          'skip',
          'track',
          t.id, {
            'properties' => { 'skip_time' =>  skip_time }
          }
        )
      end
    end
  end
end
