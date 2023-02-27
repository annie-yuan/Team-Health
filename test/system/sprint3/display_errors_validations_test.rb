require "application_system_test_case"

# 1)As a user, I should be able to view all validation error messages when a form is completed incorrectly

class DisplayErrorsValidationsTest < ApplicationSystemTestCase
  setup do
     Option.create(reports_toggled: true)
    # create prof, team, and user
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: "Smucker", is_admin: true, password: 'professor', password_confirmation: 'professor')
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'D', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'D', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!     
    user1.join_team_statuses.create(team: team, status: 1)
    user2.join_team_statuses.create(team: team, status: 1)
  end
  #Login errors
  def test_invalid_login 
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'testing'
    
    assert_text "Cannot log you in. Invalid email or password."
  end 
  #User signup errors 
  def test_invalid_signup
    visit root_url
    click_on "Sign Up"

    fill_in "user[first_name]", with: "Scott"
    fill_in "user[last_name]", with: "Scott"
    fill_in "user[admin_code]", with: "TEAM01"
    fill_in "user[email]", with: "SCOTTF@uwaterloo.ca"
    fill_in "user[password]", with: "testpassword"
    fill_in "user[password_confirmation]", with: "testpassword"
    click_on "Create account"
      
    assert_text "1 error prohibited this user from being saved:"
    assert_text "Invalid admin code."
  end
   
  def test_blank_user_signup
    visit root_url
    click_on "Sign Up"  
      
    click_on "Create account"
    assert_text "7 errors prohibited this user from being saved:"
    assert_text "Password can't be blank"
    assert_text "Email can't be blank"
    assert_text "Email must be UWaterloo email"
    assert_text "First name can't be blank"
    assert_text "Last name can't be blank"
    assert_text "Password is too short (minimum is 6 characters)"
    assert_text "Password confirmation can't be blank"
  end
  #Team signup errors 
  def test_invalid_team_signup
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url
      
    click_on "Manage Teams"
    find('#new-team-link').click
    #blank team_name
    fill_in "Team code", with: "Code 1"
    fill_in "Course code", with: "N2L3K7"
    click_on "Create Team"
      
    assert_text "1 error prohibited this team from being saved:"
    assert_text "Team name can't be blank"
  end
  #Feedback errors
  def test_invalid_feedback
    visit root_url 
    login 'charles2@uwaterloo.ca', 'banana'
    assert_current_path root_url
      
    click_on "Submit for"
    select "High", :from => "Priority"
    click_on "Create Feedback"
      
    assert_text "5 errors prohibited this feedback from being saved:"
    assert_text "Collaboration score can't be blank"
    assert_text "Communication score can't be blank"
    assert_text "Time management score can't be blank"
    assert_text "Problem solving score can't be blank"
    assert_text "Knowledge of roles score can't be blank"
  end
      
end
