class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :set_ajax, only: [:up, :down, :update_result]


  def test_method

  end

  def index
    type = params[:type]
    if type.present?
      @posts = Post.where(:type => type, :group => nil)
    else
      @posts = Post.where(:creator_id => current_user.id, :group => nil)
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
    @post.creator_id = current_user.id

    if @post.save
      if params[:post][:image_url].present?
        if !(image_url = upload_image_to_s3)
          redirect_to list_path, notice: init_message(:error, 'Upload image fail!')
        else
          @post.update(:image_url => image_url)
        end
      end
      redirect_to post_path(@post), notice: init_message(:success, 'Create Post successfully')
    else
      redirect_to posts_path, notice: init_message(:error, 'Create Post fail!')
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      if params[:post][:image_url].present?
        image_url = upload_image_to_s3
        if !image_url
          flash.now[:notice] = init_message(:error, 'Upload image fail!')
        else
          @post.update(:image_url => image_url)
        end
      end

      if @post.type == Post::TYPE_RANDOM
        redirect_to randomizes_posts_path, notice: init_message(:success, 'Update Randomise successfully!')
      else
        redirect_to votes_posts_path, notice: init_message(:success, 'Update Vote successfully!')
      end
    end
  end

  def destroy
    @post.destroy
    if @post.is_children?
      redirect_to post_path(@post.group), notice: init_message(:success, 'A child post is deleted successfully!')
    elsif @post.have_children?
      Post.destroy_all(:group => @post.id)
      redirect_to posts_path, notice: init_message(:success, 'All posts are deleted successfully!')
    else
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

    def upload_image_to_s3
      image_url = FileStore.random_file_path(ENV['AWS_S3_POST_DIR'], File.extname(params[:post][:image_url].original_filename))
      s3 = FileStore.bucket
      obj = s3.object(image_url)
      if !obj.upload_file(File.expand_path(params[:post][:image_url].tempfile), acl:'public-read')
        flash.now[:notice] = init_message(:error, 'Cannot upload image')
        return false
      end

      return image_url
    end

    def show_vote_page
      @children = Post.belongs_to_post(@post.id)
      render 'show_vote'
    end

    def show_randomizer_page
      @users = User.all.shuffle
      res = @post.result.nil? ? Post.create_random_result(@post[:number], @users.count) : [@post.result]
      @post.result = res.join(",")
      @post.save!
      @view_params = {
          result: res       
      }
      render 'show_randomizer'
    end

    def edit_vote_group_page
      render 'edit_vote_group'
    end

    def set_post
      @post = Post.find(params[:id])
    end

    def set_ajax
      @post = Post.find(params[:id])
      @ajax_message = {}
    end

    def post_params
      params.require(:post).permit(:id, :group, :cat_name, :title, :content, :up, :down, :creator_id, :result, :number, :type)
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
