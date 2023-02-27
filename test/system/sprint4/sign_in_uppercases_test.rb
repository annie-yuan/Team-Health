require "application_system_test_case"

class SignInUppercasesTest < ApplicationSystemTestCase
  setup do
    Option.create(reports_toggled: true)
    @generated_code = Team.generate_team_code
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', course: @course)
    @bob = User.create(email: 'bob@uwaterloo.ca', first_name: 'Bob', last_name: 'Smith', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.join_team_statuses.create(team: @team, status: 1)
  end
    
  def test_sign_in_regular
    visit root_url 
    # Login as student
    login 'bob@uwaterloo.ca', 'testpassword'

    assert_text "Welcome, Bob"
    
  end
    
  def test_sign_in_uppercase
    visit root_url 
    # Login as student
    login 'BOB@uwaterloo.ca', 'testpassword'

    assert_text "Welcome, Bob"
    
  end
end
