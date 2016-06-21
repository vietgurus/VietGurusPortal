class PostsController < ApplicationController
  skip_before_action :authenticate #temporarily

  def index
    @posts = Post.all
    @users_count = 10
  end

  def new_vote

  end

  def new_randomize

  end

  def show
    post = Post.find(params[:id])
    if post.type == Post::TYPE_RANDOM
      render show_random(post)
    else
      render show_vote(post)
    end
  end

  def show_vote
  end

  def show_random(post)
    @view_params = {
        post: post,
        number: post[:number],
        result: Post.creat_random_result(post[:number], 10)
    }
  end

  def update_result
    post = Post.find(params[:id])
    post.update(:result => params[:result].join(","))
    render json: {url: posts_path}
  end
end
