require "application_system_test_case"

# Acceptance Criteria
# 1. As a professor or TA, I can register to create an admin account using the admin code
# 2. As a student, I cannot register to create an admin account without the admin code

class ProfessorRegistrationPortalsTest < ApplicationSystemTestCase
  
  #(1)
  def test_signup_prof 
    Option.destroy_all
    Option.create(reports_toggled: true, admin_code: 'ADmin')
    Team.create(team_name: 'Test Team', team_code: 'TEAM01')
    
    # register new student
    visit root_url
    click_on "Sign Up"
    
    fill_in "user[first_name]", with: "Professor"
    fill_in "user[last_name]", with: "Fire"
    fill_in "user[admin_code]", with: "ADmin"
    fill_in "user[email]", with: "prof@uwaterloo.ca"
    fill_in "user[password]", with: "testpassword"
    fill_in "user[password_confirmation]", with: "testpassword"
    click_on "Create account"
    
    assert_current_path root_url
    assert_text "Welcome, Professor"
    click_on "Account" 
    assert_text 'Professor'
  end
  
  #(2)
  def test_cannot_signup_prof 
    Option.destroy_all
    Option.create(reports_toggled: true, admin_code: 'ADMIN')
    Team.create(team_name: 'Test Team', team_code: 'TEAM01')
    
    # register new student
    visit root_url
    click_on "Sign Up"
    
    fill_in "user[first_name]", with: "Professor"
    fill_in "user[last_name]", with: "Fire"
    fill_in "user[admin_code]", with: "notadmin"
    fill_in "user[email]", with: "prof@uwaterloo.ca"
    fill_in "user[password]", with: "testpassword"
    fill_in "user[password_confirmation]", with: "testpassword"
    click_on "Create account"
    
    assert_text 'Invalid admin code. Please leave admin code empty if you are a student.'
    assert_current_path users_path
  end
end
