require 'csv'
class Team < ApplicationRecord   
  validates_length_of :team_name, maximum: 40
  validates_length_of :team_code, maximum: 26
  validates_uniqueness_of :team_code, :case_sensitive => false
  validate :code_unique
  validates_presence_of :team_name
  validates_presence_of :team_code
  has_many :join_team_statuses  
  has_many :users, through: :join_team_statuses
  has_many :feedbacks
  belongs_to :course

  include FeedbacksHelper
  
  def code_unique 
    if Option.exists?(admin_code: self.team_code)
      errors.add(:team_code, 'not unique')
    end
  end
  
  def student_names 
    students = Array.new
    for student in self.active_users.to_ary
      students.push(student.first_name, student.last_name)
    end 
    return students
  end
  
  def find_priority_weighted(start_date, end_date)
    # if AT LEAST ONE of the feedbacks have a priority score of 0, meaning "urgent", the professor will see a status of "Urgent" for the respective team
    # if at least 1/3 of the feedbacks submitted have a priority score of 1, meaning "medium", the professor will see a status of "Medium" for the respective team, used float division
    # every other case is considered a priority of low since it was the default score submitted per feedback
    # array index 0 represents number of "urgent" priorities that a team has, index 1 represents number of "medium" priorities, index 2 represents number of "low" priorities
    # additionally, the priority is also determined by the average rating of the team (if rating < 2, priority is marked as high,
    # if rating = 3, priority is marked as medium and if rating is > 3, priority is marked as low )
   
    priority_holder = Array.new(3)
    #gets all feedbacks for a given week
    feedbacks = self.feedbacks.where(:timestamp => start_date..end_date)
    
    if feedbacks.count == 0
      return nil
    end
    
    priority_holder.each_with_index {|val, index| priority_holder[index] = feedbacks.where(priority: index).count}

    if priority_holder[0] > 0
      return "High" 
    elsif priority_holder[1] >= feedbacks.count/3.0
      return "Medium" 
    elsif Feedback.average_rating(feedbacks) <= 2.0
      return "High" 
    elsif Feedback.average_rating(feedbacks) == 3.0
      return "Medium" 
    else
      return "Low"
    end 
  end 
  
  #gets the average team rating for the professor's team summary view
  def self.feedback_average_rating(feedbacks)
    if feedbacks.count > 0
      (feedbacks.sum{|feedback| feedback.rating}.to_f/feedbacks.count.to_f).round(2)
    else
      return nil
    end
  end
  
  # return a multidimensional array that is sorted by time (most recent first)
  # first element of each row is year and week, second element is the list of feedback
  def feedback_by_period
    periods = {}
    feedbacks = self.feedbacks
    if feedbacks.count > 0
      feedbacks.each do |feedback| 
        week = feedback.timestamp.to_date.cweek 
        year = feedback.timestamp.to_date.cwyear
        if periods.empty? || !periods.has_key?({year: year, week: week})
          periods[{year: year, week: week}] = [feedback]
        else 
          periods[{year: year, week: week}] << feedback
        end
      end
      periods.sort_by do |key, value| 
        [-key[:year], -key[:week]]
      end
    else
      nil
    end
  end
  
  def users_not_submitted(feedbacks)
    submitted = Array.new
    feedbacks.each do |feedback|
      submitted << feedback.user
    end
    
    self.active_users.to_ary - submitted
  end
  
  def current_feedback(d=now)
    current_feedback = Array.new
    self.feedbacks.each do |feedback| 
      time = feedback.timestamp.to_datetime
      if time.cweek == d.cweek && time.cwyear == d.cwyear
        current_feedback << feedback 
      end 
    end 
    current_feedback
  end 
  
  def status(start_date, end_date)
    priority = self.find_priority_weighted(start_date, end_date)
    feedbacks = self.feedbacks.where(:timestamp => start_date..end_date)
    rating = Team::feedback_average_rating(feedbacks)
    rating = rating.nil? ? 10 : rating
    users_not_submitted = self.users_not_submitted(feedbacks)
    users_not_submitted = self.active_users.to_ary.size == 0 ? 0 : users_not_submitted.size.to_f / self.active_users.to_ary.size

    if priority == 'High'
      return 'red'
    elsif priority.nil?
      return 'grey'
    elsif priority == 'Medium'
      return 'yellow'
    elsif priority == 'Low' 
      return 'green'
    end  
  end
  
  def find_users(status)
    self.users.filter {|user| JoinTeamStatus.find_by(team: self, user: user).status == status}
  end

  def active_users()
    find_users(1)
  end

  def pending_users()
    find_users(0)
  end

  def self.generate_team_code(length = 6)
    team_code = rand(36**length).to_s(36).upcase
    
    while team_code.length != length or (Team.exists?(:team_code=>team_code) or Option.exists?(:admin_code=>team_code))
      team_code = rand(36**length).to_s(36).upcase
    end
    
    return team_code.upcase
  end

  def self.order_by field
    return Team.order(field)
  end 

  #this code is referenced from "https://findnerd.com/list/view/Importing-and-Exporting-Records-in-CSV-format-in-Rails/21377/"
  def self.to_csv
    attributes = %w{id team_code team_name created_at updated_at}
    CSV.generate(headers: true) do |csv|
    csv << attributes
    all.each do |team|
      csv << attributes.map{ |attr| team.send(attr) }
    end
  end
end
end
