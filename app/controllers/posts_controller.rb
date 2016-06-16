class PostsController < ApplicationController

  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def index
    @posts = Post.all
  end

  def show
  end

  def new
    @post = Post.new
  end

  def edit
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to posts_path, notice: init_message(:success, 'Guideline Rate was successfully created.')
    else
      render :new
    end
  end

  def update
    if @post.update(post_params)
      redirect_to posts_path, notice: init_message(:success, 'Guideline Rate was successfully updated.')
    else
      render :edit
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: init_message(:success, 'Guideline Rate was successfully destroyed.')
  end

  private
  def post_params
    params.require(:post).permit(
        :origin_location_id,
        :destination_location_id,
        :type_size_id,
        :rate
    )
  end

  def set_post
    @post = Post.find(params[:id])
  end

end
