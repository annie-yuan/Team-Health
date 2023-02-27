require "application_system_test_case"

# Acceptance Criteria: 
# 1. Student should be able to add their first and last name 
# 2. Student should be able to add their email 
# 3. Student should be able to add their student ID
# 4. Student should be able to add a password 
# 5. Student should be able to add a unique team code 
# 6. Given details are entered, when the register button is clicked, 
#    registration details should be recorded in database 
# 7. Given appropriate team code is entered, when the register button is 
#    clicked, student should be added to corresponding team

class StudentRegistrationPortalUnvalidatedsTest < ApplicationSystemTestCase
  # (1-7)
  def test_register_student  
    prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: prof)
    Team.create(team_name: 'Test Team', team_code: 'TEam01', course: course)
    
    # register new student
    visit root_url
    click_on "Sign Up"
    
    fill_in "user[first_name]", with: "Bob"
    fill_in "user[last_name]", with: "Doe"
    fill_in "user[email]", with: "bob@uwaterloo.ca"
    fill_in "user[password]", with: "testpassword"
    fill_in "user[password_confirmation]", with: "testpassword"
    click_on "Create account"
    
    assert_current_path root_url
    assert_text "Welcome, Bob"
    click_on "Logout"
    assert_current_path login_url 
    
    # check student enrollment (professor)
    # TODO: Write a test to test student enrollment when we support the feature again
    # visit root_url
    # login 'msmucker@uwaterloo.ca', 'professor'
    # assert_current_path root_url
    
    # click_on "Manage Teams"
    # assert_text 'Bob'
    # assert_text 'Test Team'
    
    # click_on "Back"
    # click_on "Manage Users"
    # assert_text 'Bob'
  end
end
