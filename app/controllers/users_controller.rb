class UsersController < ApplicationController
  skip_before_action :authenticate, only: [:create]
  before_action :init_user, only: [:show, :edit, :update, :change_password, :destroy, :update_role, :create]
  before_action :set_token, only: [:create, :update]

  def update_avatar
    user    = User.find_by(id: params[:user][:id])
    update_params = user_params
    if params[:user][:avatar]
      avatar  = params[:user][:avatar]
      image = Image.new
      image.temp_path = "/temp/#{avatar.original_filename}"
      FileStore.bucket.put_object(key: image.temp_path, body: avatar, acl: 'public-read')
      image.save
      update_params[:image_id] = image.id
    end

    if user.update(update_params)
      redirect_to users_path
    else
      flash.now[:error] = 'Something wrong! Please recheck your photo'
      redirect_to edit_user_path
    end
  end

  # GET /users
  def index
    authorize @current_user
    @users = User.all.order(:id)
    if params[:keyword]
      @users = @users.search(params[:keyword])
    else
      @users
    end
  end

  # GET /users/1
  def show
    render :edit
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    if current_user.admin?
      @user = User.new(user_params)
      update_params = user_params
      if params[:user][:avatar]
        avatar  = params[:user][:avatar]
        image = Image.new
        image.temp_path = "/temp/#{avatar.original_filename}"
        FileStore.bucket.put_object(key: image.temp_path, body: avatar, acl: 'public-read')
        image.save
        update_params[:image_id] = image.id
      end
      @user = User.new(update_params)
      @user.api_token = @token

      if @user.save
        flash.now[:notice] = 'Welcome onboard!'
        redirect_to users_path
      else
        flash.now[:error] = 'Something bad happened! Are you a guru?'
        redirect_to new_user_path
      end
    end
  end

  # PATCH/PUT /users/1
  def update
    update_params = user_params
    update_params[:token] = @token
    if @user.update(update_params)
      flash.now[:notice] = "Hey #{@user.name}! You've changed your info, any dark work?"
      flash.keep
      redirect_to edit_user_path(@user)
    else
      render :edit
    end
  end

  def update_role
    begin
      if @user.update(user_params)
        flash.now[:notice] = "#{@user.name}'s role is updated!"
        flash.keep
        redirect_to users_path
      else
        flash.now[:error] = 'Something bad happened! Are you a guru?'
        flash.keep
        redirect_to users_path
      end
    rescue StandardError
      redirect_to users_path
    end
  end

  # DELETE /users/1
  def destroy
    flash.now[:notice] = "Goodbye #{@user.name}. You broke our heart!"
    flash.keep
    @user.destroy
    redirect_to users_url
  end

  # POST /update_profile
  def update_profile
    if @current_user.update(profile_params)
      flash.now[:notice] = "Hey #{@user.name}! You've changed your info, any dark work?"
      flash.keep
      redirect_to edit_user_path(@user)
    else
      render :edit
    end
  end

  # POST /change_password
  def change_password
    current_user.is_changing_password = true

    flash.now[:error] = 'Sometimes, gurus forget their password.' unless current_user.authenticate params[:current_password]
    flash.now[:error] = 'Gurus don\'t leave password empty'       unless params[:password].present?
    flash.now[:error] = 'Gurus don\'t misstype password'          unless params[:password] == params[:password_confirmation]
    if flash.now[:error].any?
      flash.keep
      redirect_to edit_user_path(@user)
      return
    end

    if @user.update(change_password_params)
      flash.now[:notice] = 'That\'s why we call you guru! Easy job right?'
    else
      flash.now[:error] = 'Cannot update, guru'
    end

    flash.keep
    redirect_to edit_user_path(@user)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def init_user
      @user = User.find_by_id(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(
        :name, 
        :email,
        :password,
        :role,
        :image_id
      )
    end

    def role_params
      params.require(:user).permit(
          :role
      )
    end
    # Only allow a trusted parameter "white list" through.
    def profile_params
      params.require(:user).permit(
          :name
      )
    end

    # Only allow a trusted parameter "white list" through.
    def change_password_params
      params.permit(
          :password,
          :password_confirmation,
      )
    end

    def set_token
      @token = SecureRandom.hex(64)
    end

    def update_avatar_params
      params.require(:user).permit(
          :id,
          :avatar
      )
    end

end
