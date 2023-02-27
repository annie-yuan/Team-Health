require "application_system_test_case"

class RedirectHelpPathStudentTest < ApplicationSystemTestCase
  setup do
    Option.create(reports_toggled: true, admin_code: 'ADMIN')
    @generated_code = Team.generate_team_code
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'password', password_confirmation: 'password')
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @team = Team.create(team_name: 'Test Team', team_code: @generated_code.to_s, course: @course)
    @bob = User.create(email: 'bob@uwaterloo.ca', first_name: 'Bob', last_name: 'Smith', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.join_team_statuses.create(team: @team, status: 1)
    @bob.save!
  end
  
  def test_access_help_as_professor
    Option.destroy_all
    Option.create(reports_toggled: true, admin_code: 'ADMIN')
    
    visit root_url 
    # Login as professor
    login 'msmucker@uwaterloo.ca', 'password'

    visit '/help'
    
    assert_current_path help_path
  end

  def test_access_help_as_student
    Option.destroy_all
    Option.create(reports_toggled: true, admin_code: 'ADMIN')
    
    visit root_url 
    # Login as student
    login 'bob@uwaterloo.ca', 'testpassword'

    visit '/help'

    assert_current_path root_url
  end
end
