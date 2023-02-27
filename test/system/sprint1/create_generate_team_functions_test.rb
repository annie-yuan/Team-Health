require "application_system_test_case"

# Acceptance Criteria
# 1. Team details will be successfully added to database
# 2. Each team will have a unique associated code that students can use to join
# 3. Student should only be allowed to join the team they were given the code for

class CreateGenerateTeamFunctionsTest < ApplicationSystemTestCase
  # Test team can be created (1)
  def test_create_team
    # create professor 
    prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: prof)

    # log professor in
    visit root_url
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url
    
    # create new team
    click_on "Manage Teams"
    find('#new-team-link').click
    fill_in "Team name", with: "Test Team"
    fill_in "Course code", with: "N2L3K7"
    click_on "Create Team"
    assert_text "Team was successfully created."
    click_on "Home"
    click_on "Math"
    assert_text "Test Team"
    
    # log professor out
    visit root_url
    click_on "Logout"
  end 
  
  # Test student can use team code (2)
  def test_register_student  
    prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: prof)
    Team.create(team_name: 'Test Team', team_code: 'TEAM01', course: course)
    
    # register new student
    visit root_url
    click_on "Sign Up"
    
    fill_in "user[first_name]", with: "Bob"
    fill_in "user[last_name]", with: "Fire"
    fill_in "user[email]", with: "bob@uwaterloo.ca"
    fill_in "user[password]", with: "testpassword"
    fill_in "user[password_confirmation]", with: "testpassword"

    click_on "Create account"
    
    assert_current_path root_url
    assert_text "Welcome, Bob Fire"
    click_on "Logout"
    
    # check student enrollment (professor)
    assert_current_path login_url 
    visit root_url
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url
  end
  
end
