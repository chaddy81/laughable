# Testing worker that has no actual useful functionality
class WowWorker
  include Sidekiq::Worker
  sidekiq_options queue: :critical

  def perform
    1000.times { puts 'wow' }
  end
end
