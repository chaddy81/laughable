# def predictionio_up_next_event_client
#   pio_url = ENV['PIO_EVENT_SERVER_URL']
#   pio_threads = ENV['PIO_THREADS']
#   pio_key = ENV['PIO_UP_NEXT_ACCESS_KEY']

#   if pio_url.nil? || pio_threads.nil? || pio_key.nil?
#     puts 'WARNING: PredictionIO variables not set, exiting'
#     exit
#   end
#   PredictionIO::EventClient.new(pio_key, pio_url, Integer(pio_threads)) if Rails.env == 'staging' || Rails.env == 'production'
# end

# def predictionio_engine_client
#   pio_url = ENV['PIO_QUERY_SERVER_URL']
#   if pio_url.nil?
#     puts 'WARNING: PredictionIO variables not set, exiting'
#     exit
#   end
#   PredictionIO::EngineClient.new(pio_url) if Rails.env == 'staging' || Rails.env == 'production'
# end

# $pio_up_next ||= predictionio_up_next_event_client
# $pio_engine ||= predictionio_engine_client
