require "application_system_test_case"

# 1)As a user, I should be able to view all validation error messages when signup is completed incorrectly

class DisplayErrorsValidationsTest < ApplicationSystemTestCase
  setup do        
    Option.create(reports_toggled: true, admin_code: 'Admin')
  end
   
  def test_first_name_blank 
    visit root_url 
    click_on "Sign Up"
    click_on "Create account"
    assert_text "First name can't be blank"
  end

  def test_last_name_blank 
    visit root_url 
    click_on "Sign Up"
    click_on "Create account"
    assert_text "Last name can't be blank"
  end

  def test_email_blank 
    visit root_url 
    click_on "Sign Up"
    click_on "Create account"
    assert_text "Email can't be blank"
  end

  def test_uwaterloo_email 
    visit root_url 
    click_on "Sign Up"
    click_on "Create account"
    assert_text "Email must be UWaterloo email"
  end

  def test_password_blank 
    visit root_url 
    click_on "Sign Up"
    click_on "Create account"
    assert_text "Password can't be blank"
  end

  def test_password_too_short 
    visit root_url 
    click_on "Sign Up"
    click_on "Create account"
    assert_text "Password is too short (minimum is 6 characters)"
  end

  def test_password_confirmation_blank 
    visit root_url 
    click_on "Sign Up"
    click_on "Create account"
    assert_text "Password confirmation can't be blank"
  end

  def test_password_confirmation_matches 
    prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    Team.create(team_name: 'Test Team', team_code: 'TEam01')
    
    # register new student
    visit root_url
    click_on "Sign Up"
    
    fill_in "user[first_name]", with: "Bob"
    fill_in "user[last_name]", with: "Duncan"
    fill_in "user[email]", with: "bob@uwaterloo.ca"
    fill_in "user[password]", with: "testpassword"
    fill_in "user[password_confirmation]", with: "testpassword123"
    click_on "Create account"
    assert_text "Password confirmation doesn't match Password"
  end

  def test_admin_code_not_exists
    prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    Team.create(team_name: 'Test Team', team_code: 'TEam01')
    
    # register new student
    visit root_url
    click_on "Sign Up"
    
    fill_in "user[first_name]", with: "Bob"
    fill_in "user[last_name]", with: "Duncan"
    fill_in "user[admin_code]", with: "TEam02"
    fill_in "user[email]", with: "bob@uwaterloo.ca"
    fill_in "user[password]", with: "testpassword"
    fill_in "user[password_confirmation]", with: "testpassword"
    click_on "Create account"

    assert_text "Invalid admin code. Please leave admin code empty if you are a student."
  end

      
end


