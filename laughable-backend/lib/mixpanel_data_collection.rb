class MixpanelDataCollection
  include Sidekiq::Worker
  def perform
    from_date = (Time.zone.now.midnight - 1.day).strftime("%Y-%m-%d")
    to_date = Time.zone.now.midnight.strftime("%Y-%m-%d")
    expire = (Time.zone.now + 8.hours).to_i
    api_key = ENV['MIXPANEL_API_KEY']
    api_secret = ENV['MIXPANEL_API_SECRET']
    beginpoint = "https://data.mixpanel.com/api/2.0/export/?"
    args =
      {
        from_date: from_date,
        to_date: to_date,
        expire: expire,
        api_key: api_key
      }
    sig = generate_signature(args, api_secret)
    data = URI.parse("#{beginpoint}expire=#{expire}&from_date=#{from_date}&to_date=#{to_date}&api_key=#{api_key}&sig=#{sig}").read
    lines = data.split("\n")
    lines.each do |line|
      j = JSON.parse(line)
      distinct_id = j['properties']['distinct_id']
      event = j['event']
      timestamp = j['properties']['time'].to_s
      entry = MixpanelEvent.where("payload->>'time' = ?", timestamp).where(event: event, distinct_id: distinct_id).first
      if entry.nil?
        MixpanelEvent.create(
          distinct_id: distinct_id,
          event: event,
          payload: j
        )
      end
    end
    MixpanelDataCollection.perform_in(8.hours)
  end

  def generate_signature(args, api_secret)
    Digest::MD5.hexdigest(
      args.map { |key, val| "#{key}=#{val}" }
      .sort
      .join +
      api_secret
    )
  end
end
