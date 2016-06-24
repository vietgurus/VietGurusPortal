class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :set_ajax, only: [:up, :down, :update_result]

  def index
    type = params[:type]
    if type.present?
      @posts = Post.where(:type => type)
    else
      @posts = Post.where(:creator_id => current_user.id)
    end

    @posts.order!(id: :desc)
    @title = get_title type
    @users = User.all
  end

  def new_vote
    @post = Post.new(:type => Post::TYPE_VOTE)
  end

  def new_randomize
    @post = Post.new(:type => Post::TYPE_RANDOM)
  end

  def create
    @post = Post.new(post_params)
    @post.set_creator(current_user.id)


    if @post.save
      uploaded_io = post_params[:image_url]
      file_name = @post.id.to_s + (File.extname(uploaded_io.original_filename))
      File.open(Rails.root.join('public', 'images', 'uploads', file_name), 'wb') do |file|
        file.write(uploaded_io.read)
      end

      @post.update(image_url: file_name)

      if @post.type == Post::TYPE_RANDOM
        redirect_to posts_randomizes_path, notice: init_message(:success, 'Create Randomise successfully')
      else
        redirect_to posts_votes_path, notice: init_message(:success, 'Create Vote post successfully')
      end
    end
  end

  def edit
    if ! @post.authorized? current_user.id
      redirect_to posts_path, notice: init_message(:error, 'Wtf! It is not yours dude')
    end
  end

  def update
    if @post.update(post_params)
      if @post.type == Post::TYPE_RANDOM
        redirect_to posts_randomizes_path, notice: init_message(:success, 'Update Randomise successfully!')
      else
        redirect_to posts_votes_path, notice: init_message(:success, 'Update Vote successfully!')
      end
    end
  end

  def destroy
    if ! @post.authorized? current_user.id
      @post.destroy
      redirect_to posts_path, notice: init_message(:success, 'A post is deleted successfully!')
    end
  end

  def show
    if @post.type == Post::TYPE_RANDOM
      show_randomizer_page
    else
      show_vote_page
    end
  end

  def up
    if not_vote_yet?
      appended_value = [@post.up.to_s, current_user.id].delete_if(&:blank?).join(',')
      @post.update_column(:up, appended_value)
      @ajax_message[:success] = 'Thank you! You voted UP!'
    else
      @ajax_message[:error] = 'Hey! You\'ve already voted dude!'
    end
  end

  def down
    if not_vote_yet?
      appended_value = [@post.down.to_s, current_user.id].delete_if(&:blank?).join(',')
      @post.update_column(:down, appended_value)
      @ajax_message[:success] = 'Thank you! You voted DOWN!'
    else
      @ajax_message[:error] = 'Hey! You\'ve already voted dude!'
    end
  end


  def update_result
    @post.update({:result => params[:result].join(","),
                 :status => 1
                })
    render json: {url: posts_path}
  end

  private
    def not_vote_yet?
      voted_user_ids = @post.vote_result_array[:up] + @post.vote_result_array[:down]
      return ! (voted_user_ids.include? current_user.id.to_s)
    end

    def show_vote_page
      @view_params = {

      }
      render 'show_vote'
    end

    def show_randomizer_page
      @users = User.all.shuffle
      @view_params = {
          result: Post.creat_random_result(@post[:number], @users.count)
      }
      render 'show_randomizer'
    end

    def set_post
      @post = Post.find(params[:id])
    end

    def set_ajax
      @post = Post.find(params[:id])
      @ajax_message = {}
    end

    def post_params
      params.require(:post).permit(:id, :cat_name, :title, :content, :image_url, :up, :down, :creator_id, :result, :number, :type)
    end

    def get_title(type)
      case type
        when Post::TYPE_VOTE
          'Votes'
        when Post::TYPE_RANDOM
          'Randomizes'
        else
          'Your posts'
      end
    end
end
