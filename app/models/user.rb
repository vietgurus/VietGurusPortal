class User < ActiveRecord::Base
  has_secure_password
  after_initialize :set_default_role, if: :new_record?

  enum role: [:user, :leader, :admin]

  validates :email,
            uniqueness: true
  validates :name,
            uniqueness: {case_sensitive: false}

  has_attached_file :avatar, styles: {
      thumb: '100x100>',
      square: '200x200#',
      medium: '300x300>'
  }

  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  #has_one :image

  def set_default_role
    self.role ||= :user
  end

  def get_avatar_path
    "/images/avatars/" + self.id.to_s + ".jpg"
  end

  def is_changing_password=(value)
    @is_changing_password = value
  end

  def is_changing_password?
    @is_changing_password
  end

  def self.search(keywords)
    if keywords.present?
      condition = User.arel_table[:name].eq(keywords)
      keywords.split(' ').each do |keyword|
        condition = condition.or(User.arel_table[:name].        matches("%#{keyword}%"))
        condition = condition.or(User.arel_table[:email].       matches("%#{keyword}%"))
      end
      all.where(condition)
    else
      all
    end
  end

  def secure_password
    result = true
    result = false if (password =~ /[a-z]/).blank? #lower letter test
    result = false if (password =~ /[A-Z]/).blank? #upper letter test
    result = false if (password =~ /[0-9]/).blank? #number test
    result = false if password.present? && password.size < 6
    if !result
      errors.add(:base, 'Password should be contains at least')
      errors.add(:base, '1 lower letter')
      errors.add(:base, '1 upper letter')
      errors.add(:base, '1 digit letter')
      errors.add(:base, 'the length greater than 5 letters')
    end
    return result
  end

end
