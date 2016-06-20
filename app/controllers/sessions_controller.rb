class SessionsController < ApplicationController
  skip_before_action :authenticate

  def new
    @user = User.new()
    render :login, layout: nil
  end

  def create
    @user = User.find_by(email: params[:email])
    if !@user.present?
      @user = User.new()
      flash.now[:error] = 'Are you a real guru?'
      render :login, layout: nil
      return
    end
    if !@user.password == params[:password]
      flash.now[:error] = 'Are you a real guru?'
      render :login, layout: nil
      return
    end
    sessionate(@user)
    #TODO replace by dashboard path
    redirect_to root_path
  end

  def forgot_password_create
    @user = User.find_by(email: params[:email])
    if @user.present?
      @user.async_send_reset_password_email
      flash.now[:notice] = I18n.t('users.reset_password_send_mail')
    else
      flash.now[:error] = I18n.t('users.reset_password_email_not_existed')
    end
    flash.keep
    redirect_to login_path + '?type=reset-password'
  end

  def new_password_create
    @user = User.find_by(auth_token: params[:token])
    if @user.present?
      # Change token
      @user.renew_auth_token!
      if @user.update(reset_password_params)
        flash.now[:notice] = I18n.t('users.reset_password_success')
        flash.keep
        redirect_to login_path
      else
        flash.now[:error] = I18n.t('users.reset_password_fail')
        flash.keep
        redirect_to login_path + '?type=new-password&auth_token=' + params['token']
      end
    else
      flash.now[:error] = I18n.t('users.reset_password_token_fail')
      flash.keep
      redirect_to login_path + '?type=new-password&auth_token=' + params['token']
    end
  end

  def destroy
    desessionate
    redirect_to root_path
  end

  private
  def reset_password_params
    params.permit(
        :password,
        :password_confirmation
    )
  end

end
