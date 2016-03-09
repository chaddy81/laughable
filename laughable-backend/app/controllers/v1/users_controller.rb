class V1::UsersController < V1::BaseController

  before_action :user_creation_params, only: [:create]
  before_action :update_parameters_handler, only: [:update]
  before_action :check_login_parameters, only: [:login]

  def info
    render status: 200, json: { success: true }
  end

  # Returns the access token
  def login
    status = 200
    result = {}

    if @errors.empty?
      user = User.find_by(id: @user_id)
      if user.nil?
        @errors[:user_id] = 'is invalid'
        result[:success] = false
        result[:errors] = @errors
        status = 400
      else
        if user.authenticate(@password)
          result[:success] = true
          result[:access_token] = user.access_token
        else
          @errors[:password] = 'is invalid'
          result[:success] = false
          result[:errors] = @errors
          status = 400
        end
      end
    else
      result[:success] = false
      result[:errors] = @errors
      status = 400
    end
    render status: status, json: result
  end

  def create
    status = 200
    result = {}

    if @errors.empty?
      user = User.create(@parameters)
      user.save!
      result[:success] = true
      result[:user] = user.display_helper([:access_token])
    else
      status = 400
      result[:success] = false
      result[:errors] = @errors
    end

    render status: status, json: result
  end

  def show
    status = 200
    result = {}
    options_array = []

    id = params[:id]
    options = params[:options]
    options_array = options.split(',') if options.present?

    user = User.find_by(id: id)
    if user.nil?
      status = 400
      result[:success] = false
      result[:errors] = { id => "user with id #{id} does not exist" }
    else
      result[:success] = true
      display = user.display_helper(options_array + [:access_token])
      result[:user] = display
    end
    render status: status, json: result
  end

  def update
    # PUT replaces a resource entirely
    # PATCH updates values in a resource
    status = 200
    result = {}
    if @errors.empty?
      if request.put?
        current_user.update(@parameters)
      elsif request.patch?
        @parameters.delete_if { |k, v| k.nil? || v.nil? }
        current_user.update(@parameters)
      end
      result[:success] = true
      result[:user] = current_user.display_helper
    else
      status = 400
      result[:success] = false
      result[:errors] = @errors
    end
    render status: status, json: result
  end

  private

  def update_parameters_handler
    @errors = {}
    @parameters = {}
    id = current_user.id

    # Explicitly assing parameter values
    @parameters =
      {
        username: params[:user][:username],
        first_name: params[:user][:first_name],
        middle_name: params[:user][:middle_name],
        last_name: params[:user][:last_name],
        email: params[:user][:email],
        phone_number: params[:user][:phone_number]
      }
  end

  def check_login_parameters
    @user_id = params[:user_id]
    @password = params[:password]
    @errors = {}

    @errors[:user_id] = "cannot be empty" if @user_id.nil?
    @errors[:password] = "cannot be empty" if @password.nil?
  end

  def user_creation_params
    @errors = {}
    @parameters = {}

    if params[:user].nil?
      @errors[:error] = 'user hash cannot be empty'
    else
      # Explicitly assign parameter values
      attributes = params[:user]
      @parameters[:username] = attributes[:username] unless attributes[:username].nil?
      @parameters[:first_name] = attributes[:first_name] unless attributes[:first_name].nil?
      @parameters[:middle_name] = attributes[:middle_name] unless attributes[:middle_name].nil?
      @parameters[:last_name] = attributes[:last_name] unless attributes[:last_name].nil?
      @parameters[:email] = attributes[:email] unless attributes[:email].nil?
      @parameters[:password] = attributes[:password] unless attributes[:password].nil?
      @parameters[:password_confirmation] = attributes[:password_confirmation] unless attributes[:username].nil?
      @parameters[:phone_number] = attributes[:phone_number] unless attributes[:phone_number].nil?
      @parameters[:fake_user] = attributes[:fake_user] unless attributes[:fake_user].nil?
      @parameters[:beta_tester] = attributes[:beta_tester] unless attributes[:beta_tester].nil?
    end
    @parameters
  end
end
