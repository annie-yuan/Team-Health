require "application_system_test_case"

# Acceptance Criteria:
# 1. As a professor, I can view the admin code
# 2. As a professor, I can regenerate the admin code
# 3. As a student, I cannot view the admin code
# 4. As a student, I cannot regenerate the admin code

class AddAdminCodesTest < ApplicationSystemTestCase
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
    
    assert_text 'admin_CODE'
  end
  
  # (3)
  def test_cannot_view_admin_code 
    visit root_url 
    login 'bob@uwaterloo.ca', 'testpassword'
    
    assert_no_text 'admin_CODE'
  end
  
  # (2)
  def test_regenerate_admin_code 
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    
    click_on 'Regenerate Code'
    assert_current_path root_url
    assert_text 'Admin code has successfully been regenerated'
    assert_not_equal 'admin_CODE', Option.first.admin_code 
  end
  
  # (4)
  def test_cannot_regenerate_admin_code
    visit root_url 
    login 'bob@uwaterloo.ca', 'testpassword'
    
    assert_no_text 'Regenerate Code'
    
    visit regenerate_admin_code_path
    assert_text 'You do not have permission to update admin code'
    assert_equal 'admin_CODE', Option.first.admin_code 
  end
  
  def test_course_code_does_not_exist
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'

    click_on "Manage Teams"
    find('#new-team-link').click
    fill_in "Team name", with: "Test Team"
    fill_in "Team code", with: "TEAM01"
    click_on "Create Team"
    assert_text "Course code doesn't exist"
    assert_current_path new_team_path
  end
end
