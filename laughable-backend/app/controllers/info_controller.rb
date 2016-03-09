# An information controller used to retrieve information
# on various services
class InfoController < ApplicationController
  def index
    render status: 200, json: { success: true }
  end
end
