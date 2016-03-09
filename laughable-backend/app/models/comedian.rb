class Comedian < ActiveRecord::Base
  has_many :tracks

  def display_helper(options = [])
    result = {}
    default = [:id, :first_name, :last_name, :biography, :website, :twitter_name,
               :facebook_name, :instagram_name, :profile_picture,
              ]
    default += [options] if options.present?
    default.each { |attribute| result[attribute] = send(attribute) }

    change = Change.where(data_type: 'podcast', data_id: send(:id)).last if Rails.env != 'production'
    if change.present?
      change.values.keys.each do |key|
        result[key] = change.values[key]
      end if Rails.env != 'production'
    end

    result[:profile_picture] = proper_profile_picture
    result[:has_standup] = has_standup?
    result[:is_guest] = is_guest?
    result[:is_host] = is_host?
    result
  end

  def podcasts
    Podcast.where("#{send(:id)} = ANY (comedian_ids)")
  end

  def episodes
    Podcastepisode.where("#{send(:id)} = ANY (comedian_ids)")
  end

  def has_standup?
    Track.where(comedian_id: send(:id)).present?
  end

  def is_guest?
    Podcastepisode.where("#{send(:id)} = ANY (comedian_ids)").present?
  end

  def is_host?
    Podcast.where("#{send(:id)} = ANY (comedian_ids)").present?
  end

  def proper_profile_picture
    ["#{send(:profile_picture)}"]
  end
end
