class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include Pundit
  protect_from_forgery with: :exception

  before_action :authenticate, :set_locale, :init_gcal

  helper_method :current_user

  layout 'application'

  def authenticate
    redirect_to login_path if current_user.blank?
  end

  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    else
      @current_user ||= User.find_by(api_token: cookies[:token]) if cookies[:token]
    end
  end

  def sessionate(user)
    session[:user_id] = user.id
  end

  def desessionate
    session[:user_id] = nil
    session[:token] = nil
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

  def init_gcal
    @@cal ||= Google::Calendar.new(:client_id     => ENV['GCAL_CLIENT_ID'],
                                :client_secret => ENV['GCAL_CLIENT_SECRET'],
                                :calendar      => ENV['GCAL_CALENDAR_ID'],
                                :redirect_url  => ENV['GCAL_CALLBACK_URL'] # this is what Google uses for 'applications'
    )
  end
end

