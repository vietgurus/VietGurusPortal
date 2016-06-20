class PostsController < ApplicationController

  before_action :set_post, only: [:show, :edit, :update, :destroy]
  respond_to :html, :js

  def index
    @posts = Post.all
  end

  def show
    @post = Post.find(1)
    respond_to do |format|
      format.html
      format.json
    end
  end

  def new
    @post = Post.new
  end

  def up
    @post = Post.find(params[:id])
    appended_value = @post.up.to_s + ',' + '1'.to_s
    @post.update_column(:up, appended_value)
  end

  def down
    @post = Post.find(params[:id])
    appended_value = @post.down.to_s + ',' + '1'.to_s
    @post.update_column(:down, appended_value)
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
    @post = Post.find_by_id(params[:id])
  end

  skip_before_action :authenticate

end
