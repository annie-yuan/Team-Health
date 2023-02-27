require "application_system_test_case"

# Acceptance Criteria:
# 1. Student team and name should be populated when prof edits feedback

class FeedbackPopulateTest < ApplicationSystemTestCase
  setup do
    @user = User.new(email: 'test@uwaterloo.ca', password: 'asdasd', password_confirmation: 'asdasd', first_name: 'Zac', last_name: 'Brown', is_admin: false)
    @user.save
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', course: @course)
    @user.join_team_statuses.create(team: @team, status: 1)
    @course.users << @user
    
    datetime =  Time.zone.parse("2021-3-21 23:30:00")
    feedback_time = Time.zone.parse("2021-3-20 23:30:00")
    travel_to datetime
    @feedback = save_feedback(5, 5, 5, 5, 5, 5, "This team is disorganized", @user, Time.zone.now.to_datetime - 30, @team, 2)
  end 
    
  def test_population
       visit root_url 
       login 'msmucker@uwaterloo.ca', 'professor'
       click_on "Feedback & Ratings"
       assert_text "Zac Brown"
       assert_text "Test Team"
  end
end