class Post < ActiveRecord::Base
  self.inheritance_column = nil
  before_destroy :delete_image_from_s3

  TYPE_RANDOM = 2
  TYPE_VOTE = 1

  validates :content,
            presence: true
  validates :title,
            presence: true
  validates :cat_name,
            presence: true

  scope :groups, -> { where(:group => nil).order(:id => :desc) }
  scope :belongs_to_post, -> (id) { where(:group => id).order(:id => :desc) }
  scope :max_up, -> (parent_id) { where('id = :id OR posts.group = 1',
                                          { id: "#{parent_id}" } )
                                    .order('length(up) DESC')
                                    .first
                                }

  def type_name
    if self.type == TYPE_RANDOM
      'Randomizer'
    else
      'Vote'
    end
  end

  def authorized?(user_id)
    return self.creator_id.to_i == user_id.to_i
  end

  def vote_result_array
    array = {up:[], down:[]}
    if self.up.present?
      array[:up] = self.up.split(',')
    end
    if self.down.present?
      array[:down] = self.down.split(',')
    end
    array
  end

  def randomise_result_array
    array = []
    if self.result.present?
      array = self.result.split(',')
    end
    array
  end

  def have_children?
    children = Post.where(:group => self.id)
    return children.present?? children : false
  end

  def is_children?
    self.group.present?
  end

  def self.create_random_result(number_taken, total)
    shuffle_array = (0..total-1).to_a.shuffle
    shuffle_array.first(number_taken)
  end

  def self.get_groups
    groups = { "None" => [["None", ""]]}
    Post.groups.where(:type => TYPE_VOTE).group_by { |post| post[:cat_name] }.each do |category|
      name = category[0]
      groups[name] = []
      category[1].each do |post|
        groups[name] << [post.title, post.id]
      end
    end
    groups
  end

  private
    def delete_image_from_s3
      if self.image_url.present?
        s3 = FileStore.bucket
        obj = s3.object(self.image_url)
        obj.delete
      end
    end

end
