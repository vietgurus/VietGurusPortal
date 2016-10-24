class Api::V1::ApiController < ApplicationController
  protect_from_forgery with: :null_session
  around_filter :set_time_zone
  before_filter :locale
  before_filter :authenticate

  STATUS = 'status'
  MESSAGE = 'message'
  POINT = 'point'
  DATA = 'data'
  STATUS_OK = 200
  STATUS_BAD_REQUEST = 400
  STATUS_UNAUTHORIZED = 401
  STATUS_INTERNAL_SERVER_ERROR = 500

  helper_method :current_user
  rescue_from Exception, with: :error_500

  rescue_from Exception do |exception|
    logger.error exception.message
    response = {}
    response[STATUS] = STATUS_INTERNAL_SERVER_ERROR
    response[MESSAGE] = I18n.t('api.exception')
    response[DATA] = nil
    render json: response, status: STATUS_INTERNAL_SERVER_ERROR
  end

  def set_time_zone(&block)
    Time.use_zone('Beijing', &block)
  end

  def locale
    I18n.locale = :en
  end

  def authenticate
    if current_user.blank?
      response = {}
      response[STATUS] = STATUS_UNAUTHORIZED
      response[MESSAGE] = I18n.t('api.authentication_required')
      response[DATA] = nil
      render json: response, status: STATUS_UNAUTHORIZED
    end
  end

  def current_user
    if (api_token = request.headers['HTTP_API_TOKEN']).present?
      @current_user ||= User.find_by(api_token: api_token)
    end
  end
end
