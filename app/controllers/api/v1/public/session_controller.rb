class Api::V1::Public::SessionController < ApplicationController
  skip_before_action :verify_authenticity_token, :authenticate
end
