require "application_system_test_case"

# Acceptance Criteria: 
# 1. As a student, I should be able to see help instructions regarding submission of feedbacks
# 2. As a student, I should be able to see help instructions regarding submission of reports

class AddReportsTogglesTest < ApplicationSystemTestCase
  setup do
    Option.create(reports_toggled: true)
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', course: @course)
    @steve = User.create(email: 'steve@uwaterloo.ca', first_name: 'Steve', last_name: 'Smith', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @steve.join_team_statuses.create(team: @team, status: 1)
  end
  
  def test_feedback_instructions
    visit root_url 
    login 'steve@uwaterloo.ca', 'testpassword'    
    
    click_on "Submit for"
    assert_text "In group projects, there are 5 main criteria that make a successful team."
    assert_text "Collaboration"
    assert_text "Communication"
    assert_text "Time Management"
    assert_text "Problem Solving"
    assert_text "Knowledge of roles"
    assert_text "The questions below will be your overall feedback on your team's performance based upon fulfilling the above criteria. Please rate your team's performance using the below scale."
    assert_text "5 - Strongly Agree 4 - Agree 3 - Neither Agree nor Disagree (Undecided) 2 - Disagree 1 - Strongly Disagree"
  end
  
end