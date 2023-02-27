require "application_system_test_case"

# Acceptance Criteria:
# 1. Rating should be populated when prof edits feedback

class PopulateEditFeedbackWithRatingTest < ApplicationSystemTestCase
  setup do
    @user = User.new(email: 'test@uwaterloo.ca', password: 'password', password_confirmation: 'password', name: 'user', is_admin: false)
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', course: @course)
    @user.teams << @team
    @user.save
    
    datetime =  Time.zone.parse("2021-3-21 23:30:00")
    feedback_time = Time.zone.parse("2021-3-20 23:30:00")
    travel_to datetime
    @feedback = save_feedback(10, "This team is disorganized", @user, Time.zone.now.to_datetime - 30, @team, 2) 
  end 
    
  def population_test
       visit root_url 
       login 'msmucker@uwaterloo.ca', 'professor'
       
       click_on "Feedback & Ratings"
       click_on "Edit"
       assert_text "Student Name: Zac"
       assert_text "Your Current Team: Test Team"
       assert_text "10"
       assert_text "This team is disorganized"
       assert_text "Low"
    
  end
end
