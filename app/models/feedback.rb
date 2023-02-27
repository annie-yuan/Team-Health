require 'csv'
class Feedback < ApplicationRecord

  belongs_to :user
  belongs_to :team

  #requires feedback to have at minimal a rating score, comments are optional 
  validates_presence_of :collaboration_score, :communication_score,
  :time_management_score, :problem_solving_score, :knowledge_of_roles_score, :priority

  #allows a max of 2048 characters for additional comments
  validates_length_of :comments, :maximum => 2048, :message => "Please limit your comment to 2048 characters or less!"

  def format_time(given_date)
  #refomats the UTC time in terms if YYYY/MM?DD HH:MM
      #current_time = given_date.in_time_zone('Eastern Time (US & Canada)').strftime('%Y/%m/%d %H:%M')
      current_time = given_date.strftime('%Y/%m/%d %H:%M')
      return current_time
  end

  # takes list of feedbacks and returns average rating
  def self.average_rating(feedbacks)
    (feedbacks.sum{|feedback| feedback.rating}.to_f/feedbacks.count.to_f).round(2)
  end

  def self.order_by field
    if field == 'timestamp'
      return Feedback.order('timestamp')
    end
  end 

  #this code is referenced from "https://findnerd.com/list/view/Importing-and-Exporting-Records-in-CSV-format-in-Rails/21377/"
  def self.to_csv
    attributes = %w{id rating team_id user_id priority collaboration_score communication_score time_management_score problem_solving_score knowledge_of_roles_score comments timestamp created_at updated_at } 
    CSV.generate(headers: true) do |csv|
    csv << attributes
    all.each do |feedback|
      csv << attributes.map{ |attr| feedback.send(attr) }
    end
  end
end
end
