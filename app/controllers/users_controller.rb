class UsersController < ApplicationController
  before_action :init_user, only: [:show, :edit, :update, :change_password, :destroy]

  # GET /users
  def index
    @users = User.all
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
    @user.auth_token = SecureRandom.hex(64)
    if @user.save
      @user.async_send_confirmation_email
      flash.now[:notice] = I18n.t('users.sign_up_success')
      render 'sessions/login', layout: nil
    else
      flash.now[:error] = I18n.t('users.sign_up_failed')
      render 'sessions/login', layout: nil
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      flash.now[:notice] = I18n.t('users.update_success')
      flash.keep
      redirect_to edit_user_path(@user)
    else
      render :edit
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    flash.now[:notice] = I18n.t('users.destroy_success')
    redirect_to users_url
  end

  # POST /update_profile
  def update_profile
    if @current_user.update(profile_params)
      flash.now[:notice] = I18n.t('users.update_profile_success')
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
        flash.now[:error] = I18n.t('users.password_empty')
      elsif params[:password] != params[:password_confirmation]
        flash.now[:error] = I18n.t('users.password_confirmation_notmatch')
      elsif @user.update(change_password_params)
        flash.now[:notice] = I18n.t('users.change_password_success')
      else
        flash.now[:error] = I18n.t('users.change_password_failed')
      end
    else
      flash.now[:error] = I18n.t('users.current_password_notmatch')
    end
    flash.keep
    redirect_to edit_user_path(@user)
  end

  def confirm_email
    @user = User.where(auth_token: params[:auth_token]).first
    if @user.present?
      @user.email_confirmed = true
      @user.save!
    end
    flash.now[:notice] = 'Congratulation, Your account has been created successfully'
    render 'sessions/login', layout: nil
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def init_user
      @user = User.friendly.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(
        :name, 
        :email,
        :password
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
