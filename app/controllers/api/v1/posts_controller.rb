class Api::V1::PostsController < Api::V1::ApiController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # getting all posts
  def index
    type = params[:type]
    if type.present?
      @posts = Post.where(:type => type, :group => nil)
    else
      @posts = Post.where(:creator_id => current_user.id, :group => nil)
    end

    @posts.order!(id: :desc)
    render json: @posts
  end

  # creating new posts
  def create
    @post = Post.new(post_params)
    @post.creator_id = current_user.id

    if @post.save!
      if params[:post][:image_url].present?
        if !(image_url = upload_image_to_s3)
          render json: {error: 'Upload image fail!'}
        else
          @post.update(:image_url => image_url)
        end
      end
      render json: {success: 'Create Post successfully'}
    else
      render json: {fail: "Create post unsuccessfully"}
    end
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
        render json: {success: 'Update Randomise successfully!'}
      else
        render json: {success: 'Update Vote successfully!'}
      end
    end
  end

  def destroy
    @post.destroy
    if @post.is_children?
      redirect_to post_path(@post.group), notice: init_message(:success, 'A child post is deleted successfully!')
    elsif @post.have_children?
      Post.destroy_all(:group => @post.id)
      render json: {success: 'All posts are deleted successfully!'}
    else
      render json: {success: 'A post is deleted successfully!'}
    end
  end

  def up
    @post = Post.find_by(id: params[:post_id])
    render json:{success: false, message: "Random not found"} if @post.nil?
    if not_vote_yet?
      appended_value = [@post.up.to_s, current_user.id].delete_if(&:blank?).join(',')
      @post.update_column(:up, appended_value)
      render json: {success: true}
    else
      render json: {success: false, message: "already voted"}
    end
  end

  def down
    @post = Post.find_by(id: params[:post_id])
    if not_vote_yet?
      appended_value = [@post.down.to_s, current_user.id].delete_if(&:blank?).join(',')
      @post.update_column(:down, appended_value)
      render json: {success: true}
    else
      render json: {success: false, message: "already voted"}
    end
  end

  def update_random
    @post = Post.find_by(id: params[:post_id])
    @users = User.all.shuffle
    res = Post.creat_random_result(@post[:number], @users.count)
    @post.result = res.join(",")
    if @post.save!
      render json: {success: true}
    else
      render json: {success: false}
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
    return !(voted_user_ids.include? current_user.id.to_s)
  end

  def upload_image_to_s3
    image_url = FileStore.random_file_path(ENV['AWS_S3_POST_DIR'], File.extname(params[:post][:image_url].original_filename))
    s3 = FileStore.bucket
    obj = s3.object(image_url)
    if !obj.upload_file(File.expand_path(params[:post][:image_url].tempfile), acl: 'public-read')
      flash.now[:notice] = init_message(:error, 'Cannot upload image')
      return false
    end

    return image_url
  end

  private
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

end
