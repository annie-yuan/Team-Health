require "application_system_test_case"

# Acceptance Criteria:
# 1. Course code should be displayed on the courses page 
# 2. Course code should be displayed in Manage Teams 
# 3. Course code should be displayed for each team
# 4. Course code should be displayed in each course view page 
# 5. Course code should be displayed in edit team view 

class DisplayCourseCodeForInstructorTest < ApplicationSystemTestCase
  setup do
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @course = Course.create(course_name: 'Calculus', course_code: 'N2L3K7', admin: @prof)
    @team = Team.create(team_name: 'Test team', team_code: "AHABABA", course: @course)
  end
    
  def test_course_code_displayed_on_course_page
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_text "N2L3K7"
  end

  def test_course_code_displayed_in_manage_teams
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    click_on "Manage Teams"
    assert_text "N2L3K7"
  end

  def test_course_code_displayed_for_each_team
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    click_on "Calculus"
    click_on "Details"
    assert_text "N2L3K7"
  end

  def test_course_code_displayed_in_each_course_page
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    click_on "Calculus"
    assert_text "N2L3K7"
  end

  def test_course_code_displayed_in_edit_team
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    click_on "Manage Teams"
    click_on "Edit"
    assert_text "Course code"
  end
end 