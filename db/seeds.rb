# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

option = Option.create(reports_toggled: false)
option.generate_admin_code(6)

email = 'msmucker@uwaterloo.ca'
first_name = 'Mark'
last_name = 'Smucker'
password = 'professor'

prof = User.create(email: email, first_name: first_name, last_name: last_name, is_admin: true, password: password, password_confirmation: password)