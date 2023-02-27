require "application_system_test_case"

# Acceptance Criteria:
# 1. User should be able to change their password given the correct existing password 
# 2. User should not be able to change their password without the correct existing password

class AddChangePasswordsTest < ApplicationSystemTestCase
  def test_change_password 
    User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')

    # log professor in
    visit root_url
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url
    click_on "Account"
    click_on 'Change Password'
    fill_in "existing_password", with: 'professor'
    fill_in "password", with: 'professor2'
    fill_in "password_confirmation", with: 'professor2'
    
    click_on 'Submit'
    
    assert_text 'Password successfully updated!'
    click_on 'Logout'
    
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path login_url 
    
    login 'msmucker@uwaterloo.ca', 'professor2'
    assert_current_path root_url
  end
  
  def test_change_password_incorrect_existing
    User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')

    # log professor in
    visit root_url
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url
    click_on "Account" 
    click_on 'Change Password'
    fill_in "existing_password", with: 'professor2'
    fill_in "password", with: 'professor3'
    fill_in "password_confirmation", with: 'professor3'
    
    click_on 'Submit'
    
    assert_text 'Incorrect existing password'
    click_on 'Back'
    click_on 'Logout'
    
    login 'msmucker@uwaterloo.ca', 'professor3'
    assert_current_path login_url 
    
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url
  end
end
