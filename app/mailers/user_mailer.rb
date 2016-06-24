class UserMailer < ApplicationMailer
  default from: ENV['MAILER_FROM']

  def forgot_password_request(user)
    @user = user
    mail(to: @user.email, subject: '[Auto Pricing] Reset password')
  end

  def confirmation(user)
    @user = user
    mail(to: @user.email, subject: '[Auto Pricing] Email Confirmation')
  end
end
