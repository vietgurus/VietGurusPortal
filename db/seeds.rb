# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'csv'

CSV.foreach(Rails.root.join('db/seeds/users.csv'), headers: true) do |row|
  user = User.find_or_create_by(name: row[0])
  user.password = row[1]
  user.email = row[2]
  user.save!
end