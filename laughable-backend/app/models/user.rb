class User < ActiveRecord::Base
  has_secure_password(validations: false)

  after_create :create_api_key

  def display_helper(options = [])
    result = {}
    default = [:id, :username, :first_name,
               :middle_name, :last_name, :email, :phone_number]

    default += [options] if options.present?
    default.flatten!
    default.uniq!
    default.each { |attribute| result[attribute] = send(attribute) }
    result
  end

  def create_api_key
    apikey = ApiKey.new({ user_id: id })
    apikey.save
  end

  def access_token
    ApiKey.find_by(user_id: id).access_token
  end

  def comedian_subscribe(comedian_id)
    user_id = send(:id)
    entry =
      {
        user_id: user_id,
        comedian_id: comedian_id,
        subscription_date: Time.now,
        active: true
      }

    # Find all old subscriptions to this user and make sure they are active = false

    ComedianSubscription.where(user_id: send(:id), comedian_id: comedian_id, active: true).each do |subscription|
      subscription.active = false
      subscription.save!
    end

    subscription = ComedianSubscription.new(entry)
    subscription.save!
  end

  def comedian_unsubscribe(comedian_id)
    ComedianSubscription.where(user_id: send(:id), comedian_id: comedian_id, active: true).each do |subscription|
      subscription.active = false
      subscription.save!
    end
  end

  def comedian_subscriptions
    ComedianSubscription.where(user_id: send(:id), active: true).to_a
  end

  def podcast_subscriptions
    PodcastSubscription.where(user_id: send(:id), active: true).to_a
  end

  def podcast_subscribe(podcast_id)
    user_id = send(:id)
    entry =
      {
        user_id: user_id,
        podcast_id: podcast_id,
        subscription_date: Time.now,
        active: true
      }
    # Find all old subscriptions by this user and make sure they are active = false
    PodcastSubscription.where(user_id: user_id, podcast_id: podcast_id, active: true).each do |subscription|
      subscription.active = false
      subscription.save!
    end

    subscription = PodcastSubscription.new(entry)
    subscription.save!
  end

  def podcast_unsubscribe(podcast_id)
    PodcastSubscription.where(user_id: user_id, podcast_id: podcast_id, active: true).each do |subscription|
      subscription.active = false
      subscription.save!
    end
  end

  def admin?
    send(:admin)
  end
end
