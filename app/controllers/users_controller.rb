class UsersController < ApplicationController
  skip_before_action :authenticate, only: [:create]
  before_action :init_user, only: [:show, :edit, :update, :change_password, :destroy, :update_role, :create]

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
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      flash.now[:notice] = 'Welcome onboard!'
      render 'sessions/login', layout: nil
    else
      flash.now[:error] = 'Something bad happened! Are you a guru?'
      render 'sessions/login', layout: nil
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
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
    if current_user.authenticate params[:current_password]

      if !params[:password].present?
        flash.now[:error] = 'Gurus don\'t leave password empty'
      elsif params[:password] != params[:password_confirmation]
        flash.now[:error] = 'Gurus don\'t misstype password'
      elsif @user.update(change_password_params)
        flash.now[:notice] = 'That\'s why we call you guru! Easy job right?'
      else
        flash.now[:error] = 'Try again, guru'
      end
    else
      flash.now[:error] = 'Sometimes, gurus forget their password.'
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
        :role
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
          :password_confirmation
      )
    end
end
