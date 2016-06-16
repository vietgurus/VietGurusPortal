class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # before_action :authenticate
  before_action :set_locale

  helper_method :current_user

  layout 'application'

  def authenticate
    redirect_to login_path if current_user.blank?
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def sessionate(user)
    session[:user_id] = user.id
  end

  def desessionate
    session[:user_id] = nil
    @current_user = nil
  end

  def set_locale
    I18n.locale = extract_locale_from_tld || params[:locale] ||  I18n.default_locale
  end

  # Get locale from top-level domain or return nil if such locale is not available
  def extract_locale_from_tld
    parsed_locale = request.host.split('.').last
    return %w(cn).include?(parsed_locale) ? :zh : nil
  end

  helper_method :current_user

  def track_activity(trackable, action = params[:action])
    current_user.activities.create! action: action.to_sym, trackable: trackable
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end

  [:success, :error, :info, :warning]
  def init_message(type, message, title = nil)
    result = {}
    result[:success] = message if type == :success
    result[:error] = message if type == :error
    result[:info] = message if type == :info
    result[:warning] = message if type == :warning
    result[:title] = title
    result.to_json
  end

end

