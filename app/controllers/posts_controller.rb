class PostsController < ApplicationController
  skip_before_action :authenticate #temporarily
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def index
    @posts = Post.all
    @users_count = 10
  end

  def new_vote
    @post = Post.new(:type => Post::TYPE_VOTE)
  end

  def new_randomize
    @post = Post.new(:type => Post::TYPE_RANDOM)
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      if @post.type == Post::TYPE_RANDOM
        redirect_to posts_path(type: 'randomize'), notice: init_message(:success, 'Create randomize post successfully')
      else
        redirect_to posts_path(type: 'vote'), notice: init_message(:success, 'Create vote post successfully')
      end
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      if @post.type == Post::TYPE_RANDOM
        redirect_to posts_path(type: 'randomize'), notice: init_message(:success, 'Update randomize post successfully')
      else
        redirect_to posts_path(type: 'vote'), notice: init_message(:success, 'Update vote post successfully')
      end
    end
  end

  def destroy
    @post.destroy
  end

  def show
    post = Post.find(params[:id])
    render posts_path(post)
  end

  def show_vote(post)
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

  private
  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:id, :cat_name, :title, :content, :image_url, :up, :down, :creator_id, :result, :number, :type)
  end
end
