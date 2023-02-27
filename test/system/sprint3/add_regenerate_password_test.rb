require "application_system_test_case"

# Acceptance Criteria:
# 1. As a professor, I can view the regenerate password button 
# 2. As a professor, I can regenerate the password code

class AddRegeneratePasswordsTest < ApplicationSystemTestCase
  setup do 
    # create prof, team, and user
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', course: @course)
    @bob = User.create(email: 'bob@uwaterloo.ca', first_name: 'Bob', last_name: 'Smith', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.join_team_statuses.create(team: @team, status: 1)
    
    Option.destroy_all
    Option.create(reports_toggled: true, admin_code: 'admin_CODE')
  end 
  
  # (1)
  def test_view_admin_code 
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    visit user_url(@bob)
    assert_text 'Regenerate Password'
  end
  
  # (3)
  def test_cannot_view_admin_code 
    visit root_url 
    login 'bob@uwaterloo.ca', 'testpassword'
    visit user_url(@bob)
    assert_no_text 'Regenerate Password'
  end
  
  # (2)
  def test_regenerate_admin_code 
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    visit user_url(@bob)
    click_on 'Regenerate Password'
    assert_current_path root_url
    assert_text "#{@bob.name}'s new password is "
  end

end
