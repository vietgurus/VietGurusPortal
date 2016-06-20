class Post < ActiveRecord::Base

  self.inheritance_column = nil

  TYPE_RANDOM = 2
  TYPE_VOTE = 1

  def self.creat_random_result(number_taken, total)
    shuffle_array = (0..total-1).to_a.shuffle
    shuffle_array.first(number_taken)
  end

end
