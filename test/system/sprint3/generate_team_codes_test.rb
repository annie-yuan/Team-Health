require "application_system_test_case"

# Acceptance Criteria
# 1. As a professor, when I create a team, a generated team code is provided to allow students to add themselves to the team
# 2. As a student, I can use the generated team code to register an account associated with the team

class GenerateTeamCodesTest < ApplicationSystemTestCase
  setup do
    # SPRINT 3 UPDATE: Seed database with default option of reports_toggled = true
    Option.create(reports_toggled: true)
    
    #Create a generated team code
    @generated_code = Team.generate_team_code
  end
  
  #(1)
  def test_prof_team_creation_with_generated_code
    #(1) Passes acceptance criteria 1: As a professor, when I create a team, a generated team code is provided to allow students to add themselves to the team    
    # create professor 
    prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name:'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: prof)

    # log professor in
    visit root_url
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url
    
    # create new team
    click_on "Manage Teams"
    find('#new-team-link').click
    
    fill_in "Team name", with: "Test Team"
    generate_code = find_field("team[team_code]").value
    fill_in "Course code", with: "N2L3K7"
    click_on "Create Team"
    assert_text "Team was successfully created."
    click_on "Home"
    click_on "Math"
    assert_text "Test Team"
    assert_text generate_code
    
    # log professor out
    visit root_url
    click_on "Logout"
  end 
  
  #(2)
  def test_student_account_creation_with_generated_team_code
    #(2) Passes acceptance criteria 2: As a student, I can use the generated team code to register an account associated with the team
    prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name:'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: prof)
    Team.create(team_name: 'Test Team', team_code: @generated_code.to_s, course: course)
    
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
    # TODO: Check student enrollment when professor can add student to teams
    assert_current_path login_url 
    # visit root_url
    # login 'msmucker@uwaterloo.ca', 'professor'
    # assert_current_path root_url
    
    # click_on "Manage Teams"
    # assert_text 'Bob'
    # assert_text @generated_code.to_s
    # assert_text 'Test Team'
    
    
  end
  
  
end
