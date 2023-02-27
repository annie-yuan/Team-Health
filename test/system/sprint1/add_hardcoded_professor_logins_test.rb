require "application_system_test_case"

# Acceptance Criteria: 
# 1. Given the right email and password are entered on the login page,
#    when the login button is clicked, I should be redirected to the team
#    summary page 
# 2. Given the incorrect email and password are entered on the login page,
#    when the login button is clicked, I should not be redirected to the 
#    team summary page

class AddHardcodedProfessorLoginsTest < ApplicationSystemTestCase
  # Test if professor can login using correct credentials (1)
  def test_login_professor
    # create professor 
    Rails.application.load_seed

    # log professor in
    visit root_url
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url
    
    # log professor out
    visit root_url
    click_on "Logout"
  end 
  
  # Test that invalid credentials cannot access system (2)
  def test_invalid_login_professor
    # create professor 
    Rails.application.load_seed

    # log invalid professor in
    visit root_url
    login 'msmucker2@uwaterloo.ca', 'professor'
    assert_current_path login_url
  end
end
