class Event
  include ActiveModel::Model

  attr_accessor :title, :location, :calendar, :quickadd, :attendees, :description, :creator_name
  attr_accessor :color_id, :guests_can_invite_others, :guests_can_see_other_guests, :start_time, :end_time, :all_day
    validates :title,
              presence: true
end
