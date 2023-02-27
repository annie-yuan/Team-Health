require "application_system_test_case"

# 1. As a professor, I should be able to see student's that have not 
#    submitted feedbacks for team summary view
# 2. As a professor, I should be able to see student's that have not 
#    submitted feedbacks for team detailed view

class ListUsersWithoutSubmissionsTest < ApplicationSystemTestCase
  setup do
    # create prof, team, and user
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Test1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Test2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles3', last_name: 'Test3', is_admin: false)
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!     
    user1.join_team_statuses.create(team: team, status: 1)
    user2.join_team_statuses.create(team: team, status: 1)
    user3.join_team_statuses.create(team: team, status: 1)
    
    feedback = save_feedback(5, 5, 5, 5, 5, 5, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2)
    feedback2 = save_feedback(2, 2, 2, 2, 2, 2, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2)
  end
  
  # (1)
  def test_not_submitted_feedback_summary_view 
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url 
    click_on 'Math'
    assert_text "Missing Feedback"
    assert_text "Charles3 "
  end 
  
  # (2)
  def test_not_submitted_feedback_detailed_view 
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url 
    click_on 'Math'
    click_on "Details"
    
    assert_text "Missing Feedback: Charles3"
  end 
end
