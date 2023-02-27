require "application_system_test_case"

# Acceptance Criteria: 
# 1. As a professor, I should be able to see team summary of latest period
# 2. As a professor, I should be able to see detailed team ratings 
#    for specific teams based on time periods

class GroupFeedbackByPeriodsTest < ApplicationSystemTestCase
  include FeedbacksHelper
  
  setup do 
    @week_range = week_range(2021, 7)
    #sets the app's date to week of Feb 15 - 21, 2021 for testing
  end 
  
  # def save_feedback(rating, comments, user, timestamp, team)
  #   feedback = Feedback.new(rating: rating, comments: comments)
  #   feedback.user = user
  #   feedback.timestamp = feedback.format_time(timestamp)
  #   feedback.team = team
  #   feedback.save
  #   feedback
  # end 
  
  # (1)
  def test_team_summary_by_period
    travel_to Time.new(2021, 02, 15, 06, 04, 44)
    prof = User.create(email: 'msmucker@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Mark', last_name:'Smucker', is_admin: true)
    course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: prof)
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: course)
    team.save!
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name:'test1', is_admin: false)
    user1.join_team_statuses.create(team: team, status: 1)
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name:'test2',  is_admin: false)
    user2.join_team_statuses.create(team: team, status: 1)
    
    feedback1 = save_feedback(5,5,5,5,5,5, "Data1", user1, DateTime.civil_from_format(:local, 2022, 02, 15), team, 2)
    feedback2 = save_feedback(1,1,1,1,1,1, "Data2", user2, DateTime.civil_from_format(:local, 2022, 02, 16), team, 2)
    
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'banana'
    assert_current_path root_url 
    click_on 'Math'
    assert_text 'Current Week: ' + @week_range[:start_date].strftime('%b %e, %Y').to_s + " to " + @week_range[:end_date].strftime('%b %e, %Y').to_s
    assert_text 'Team 1'
  end 
  
  # (2)
  def test_view_by_period
    travel_to Time.new(2021, 03, 22, 06, 04, 44)
    prof = User.create(email: 'msmucker@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Mark', last_name:'Smucker', is_admin: true)
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name:'test1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name:'test2',  is_admin: false)
    user2.save!
    course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: prof)
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: course)
    team.save!

    feedback = save_feedback(5,5,5,5,5,5, "Week 9 data 1", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 0)
    feedback2 = save_feedback(5,5,5,5,5,5, "Week 9 data 2", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2)
    feedback3 = save_feedback(5,5,5,5,5,5, "Week 7 data 1", user1, DateTime.civil_from_format(:local, 2021, 2, 15), team, 1)
    feedback4 = save_feedback(5,5,5,5,5,5, "Week 7 data 2", user2, DateTime.civil_from_format(:local, 2021, 2, 16), team, 2)
    
    average_rating_1 = ((5 + 5).to_f/2).round(2)
    average_rating_2 = ((5 + 5).to_f/2).round(2)
    
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'banana'
    assert_current_path root_url 
    click_on 'Math'
    click_on 'Details'
    assert_current_path team_path(team)
    within('#2021-7') do
      assert_text 'Feb 15, 2021 to Feb 21, 2021'
      assert_text 'Average Rating of Period: ' + average_rating_2.to_s
      assert_text 'Weighted Priority: Medium'
      assert_text 'Missing Feedback: All submitted!'
      assert_text 'Collaboration'
      assert_text 'Communication'
      assert_text 'Time Management'
      assert_text 'Problem Solving'
      assert_text 'Knowledge of Roles'
      assert_text 'Week 7 data 1'
      assert_text 'Week 7 data 2'
      assert_text '2021-02-15'
      assert_text '2021-02-16'
    end
    within('#2021-9') do
      assert_text 'Mar 1, 2021 to Mar 7, 2021'
      assert_text 'Average Rating of Period: ' + average_rating_1.to_s
      assert_text 'Weighted Priority: High'
      assert_text 'Missing Feedback: All submitted!'
      assert_text 'Collaboration'
      assert_text 'Communication'
      assert_text 'Time Management'
      assert_text 'Problem Solving'
      assert_text 'Knowledge of Roles'
      assert_text 'Week 9 data 1'
      assert_text 'Week 9 data 2'
      assert_text '2021-03-01'
      assert_text '2021-03-03'
    end
  end
end
