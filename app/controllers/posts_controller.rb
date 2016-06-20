class PostsController < ApplicationController
  skip_before_action :authenticate

end
