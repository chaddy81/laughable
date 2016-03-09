class ApiKey < ActiveRecord::Base
  belongs_to :user
  before_create :generate_access_token

  def user
    User.find_by(id: send(:user_id))
  end

  private

  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end
end
