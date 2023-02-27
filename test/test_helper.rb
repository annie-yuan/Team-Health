require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  #parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #fixtures :all

  # Add more helper methods to be used by all tests here...
  def login(email, password)
    assert_current_path login_url
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_on "Login"
  end 
  
  def save_feedback(collaboration_score, communication_score, time_management_score, problem_solving_score, 
    knowledge_of_roles_score, rating, comments, user, timestamp, team, priority)
    feedback = Feedback.new(collaboration_score: collaboration_score, communication_score: communication_score, 
    time_management_score: time_management_score, problem_solving_score: problem_solving_score, 
    knowledge_of_roles_score: knowledge_of_roles_score, rating: rating, comments: comments, priority: priority)
    feedback.user = user
    feedback.timestamp = feedback.format_time(timestamp)
    feedback.team = team
    feedback.save
    feedback
  end 

  def feedback_rating_calculation(collaboration_score, communication_score, time_management_score, problem_solving_score, 
    knowledge_of_roles_score)
    #taken directly from the logic used in the feedbacks controller create method
    rating = ((collaboration_score.to_f + communication_score.to_f + time_management_score.to_f +
    problem_solving_score.to_f + knowledge_of_roles_score.to_f)/5.0).round(1)
  end
end
