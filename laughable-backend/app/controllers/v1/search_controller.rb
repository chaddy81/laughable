class V1::SearchController < V1::BaseController
  before_action :validate_access_token

  def info
    render status: 200, json: { result: true }
  end

  def search
    result = {}
    status = 200
    query = params[:q]

    if query.present?
      result[:success] = true
      result[:results] = {}
      result[:results][:comedians] = []
      result[:results][:tracks] = []
      result[:results][:podcasts] = []
      result[:results][:episodes] = []
      Comedian.where("name LIKE ?", "%#{query}%").each do |c|
        result[:results][:comedians] << c.display_helper
      end
      Comedian.where("biography LIKE ?", "%#{query}%").each do |c|
        result[:results][:comedians] << c.display_helper
      end
      Track.where("title LIKE ?", "%#{query}%").each do |c|
        result[:results][:tracks] << c.display_helper
      end
      Track.where("author LIKE ?", "%#{query}%").each do |c|
        result[:results][:tracks] << c.display_helper
      end
      Podcast.where("title LIKE ?" "%#{query}%").each do |c|
        result[:results][:podcasts] << c.display_helper
      end
      Podcast.where("summary LIKE ?" "%#{query}%").each do |c|
        result[:results][:podcasts] << c.display_helper
      end
      Podcastepisode.where("title LIKE ?" "%#{query}%").each do |c|
        result[:results][:episodes] << c.display_helper
      end
      Podcastepisode.where("description LIKE ?" "%#{query}%").each do |c|
        result[:results][:episodes] << c.display_helper
      end
    else
      result[:success] = false
      status = 400
    end
    render status: status, json: result
  end
end
