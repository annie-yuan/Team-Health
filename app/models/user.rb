require 'csv'
class User < ApplicationRecord
  before_save { self.email = email.downcase }  

  # This line of code (unless: ->(user){user.email.present?}) will skip the validation
  # if the user already exists in the database to allow for updating first & last name
  # Reference code: https://stackoverflow.com/questions/23591768/skip-validation-on-few-fields
  validates_presence_of :password, unless: ->(user){user.email.present?}

  before_save { self.email = email.downcase }
  validates_presence_of :email, on: :create
  validates_length_of :email, maximum: 255, on: :create
  validates_uniqueness_of :email, case_sensitive: false
  validates_format_of :email, with: /\A([^@\s]+)@(uwaterloo.ca)\z/i, :message => "must be UWaterloo email", on: :create

  validates_presence_of :first_name
  validates_length_of :first_name, maximum: 40
  validates_presence_of :last_name
  validates_length_of :last_name, maximum: 40

  # validates_presence_of :teams

  validates_presence_of :email, on: :create
  
  validates_length_of :email, maximum: 255, on: :create  
  validates_uniqueness_of :email, case_sensitive: false    
  validates_format_of :email, with: /\A([^@\s]+)@(uwaterloo.ca)\z/i, :message => "must be UWaterloo email", on: :create
  validates_uniqueness_of :email
 
  has_secure_password
  # This line of code (unless: ->(user){user.email.present?}) will skip the validation
  # if the user already exists in the database to allow for updating first & last name
  # Reference code: https://stackoverflow.com/questions/23591768/skip-validation-on-few-fields
  validates_presence_of :password, unless: ->(user){user.email.present?}
  validates_length_of :password, minimum: 6, on: :create 
  validates_presence_of :password_confirmation, on: :create

  has_many :join_team_statuses
  has_many :teams, through: :join_team_statuses
  has_many :feedbacks
  has_and_belongs_to_many :courses

  include FeedbacksHelper
  def name
    return "#{self.first_name} #{self.last_name}"
  end

  def managed_courses
    if not self.is_admin
      return nil
    else
      return Course.where(admin: self)
    end
  end

  def managed_teams
    if not self.is_admin
      return Array.new
    else
      return Team.where(course_id: [self.managed_courses.map { |course| course.id }])
    end
  end

  def managed_students
    if not self.is_admin
      return Array.new
    else
      return User.distinct.joins(:courses).where(courses: {id: [self.managed_courses.map { |course| course.id }]})
    end
  end

  def managed_feedbacks
    if not self.is_admin
      return Array.new
    else
      return self.managed_students.map { |student| student.feedbacks}.flatten
    end
  end

  def role
    if self.is_admin
      return 'Professor'
    else
      return 'Student'
    end
  end

  def team_names
    teams = Array.new
    for team in self.active_teams.to_ary
      teams.push(team.team_name)
    end
    return teams
  end

  def course_names
    courses = Array.new
    for course in self.courses.to_ary
      courses.push(course.course_name)
    end
    return courses
  end

  def find_teams(status)
    self.teams.filter {|team| JoinTeamStatus.find_by(team: team, user: self).status == status}
  end

  def active_teams()
    find_teams(1)
  end

  def pending_teams()
    find_teams(0)
  end

  # Checks whether given user has submitted feedback for the current week
  # returns array containing all teams that do not have feedback submitted feedback for that
  # team during the week.
  def rating_reminders()
    teams = []
    d = now
    days_till_end = days_till_end(d, d.cweek, d.cwyear)
    self.active_teams.each do |team|
      match = false
      team.feedbacks.where(user_id: self.id).each do |feedback|
        test_time = feedback.timestamp.to_datetime
        match = match || (test_time.cweek == d.cweek && test_time.cwyear == d.cwyear)
      end
      if !match
        teams.push team
      end
    end
    # teams
    return teams
  end

  def one_submission_teams()
    teams = []
    d = now
    days_till_end = days_till_end(d, d.cweek, d.cwyear)
    self.active_teams.each do |team|
      match = false
      team.feedbacks.where(user_id: self.id).each do |feedback|
        test_time = feedback.timestamp.to_datetime
        match = match || (test_time.cweek == d.cweek && test_time.cwyear == d.cwyear)
      end
      if match
        teams.push team
      end
    end
    # teams
    return teams
  end
  

   def reset_password
    return generate_token
   end
   
   private
   def generate_token
    SecureRandom.hex(10)
   end
   
  #this code is referenced from "https://findnerd.com/list/view/Importing-and-Exporting-Records-in-CSV-format-in-Rails/21377/"
  def self.to_csv
    attributes = %w{id email first_name last_name is_admin created_at updated_at}
    CSV.generate(headers: true) do |csv|
    csv << attributes
    all.each do |user|
      csv << attributes.map{ |attr| user.send(attr) }
    end
  end
end
end

