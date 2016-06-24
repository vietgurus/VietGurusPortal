class Post < ActiveRecord::Base

  self.inheritance_column = nil

  TYPE_RANDOM = 2
  TYPE_VOTE = 1

  validates :content,
            presence: true
  validates :title,
            presence: true
  validates :cat_name,
            presence: true

  def type_name
    if self.type == TYPE_RANDOM
      'Randomizer'
    else
      'Vote'
    end
  end

  def set_creator(id)
    self.creator_id = id
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

  def self.creat_random_result(number_taken, total)
    shuffle_array = (0..total-1).to_a.shuffle
    shuffle_array.first(number_taken)
  end

end
