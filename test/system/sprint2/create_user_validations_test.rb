require "application_system_test_case"

#Acceptance criteria
#1) As a user, I cannot create an account with a duplicate email
#2) As a user, I cannot create a student account with an invalid team code
#3) As a user, I cannot create a student account with a duplicate student number
#4) As a user, I cannot create an account with a password less than 6 characters

class CreateUserValidationsTest < ApplicationSystemTestCase
    def setup
      Option.create(reports_toggled: true)
      prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
      course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: prof)
      team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', course: course)
      user = User.create(email: 'scottf@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Scott', last_name:'F', is_admin: false)
      user.join_team_statuses.create(team: team, status: 1)
    end
    #1) As a user, I cannot create an account with a duplicate email
    def test_create_duplicate_user_email
      # register new student
      visit root_url
      click_on "Sign Up"

      fill_in "user[first_name]", with: "Scott"
      fill_in "user[last_name]", with: "Pham"
      fill_in "user[email]", with: "SCOTTF@uwaterloo.ca"
      fill_in "user[password]", with: "testpassword"
      fill_in "user[password_confirmation]", with: "testpassword"
      click_on "Create account"
      assert_current_path users_url 
    end
    
    def test_create_invalid_user_email
      # register new student
      visit root_url
      click_on "Sign Up"

      fill_in "user[first_name]", with: "Scott"
      fill_in "user[last_name]", with: "Pham"
      fill_in "user[email]", with: "scott"
      fill_in "user[password]", with: "testpassword"
      fill_in "user[password_confirmation]", with: "testpassword"
      click_on "Create account"
      assert_current_path users_url 
    end
   
    # Criteria 3 deleted since student numbers (user_id) was removed and it is obsolete. 
    
    #4) As a user, I cannot create an account with a password less than 6 characters
    def test_create_invalid_password
      # register new student
      visit root_url
      click_on "Sign Up"

      fill_in "user[first_name]", with: "Scott"
      fill_in "user[last_name]", with: "Pham"
      fill_in "user[email]", with: "scottfraser@uwaterloo.ca"
      fill_in "user[password]", with: "abcde"
      fill_in "user[password_confirmation]", with: "abcde"
      click_on "Create account"
      assert_current_path users_url 
        
    end
    
    def test_create_valid 
      #valid account
      visit root_url
      click_on "Sign Up"
        
      fill_in "user[first_name]", with: "Scott"
      fill_in "user[last_name]", with: "Pham"
      fill_in "user[email]", with: "larry@uwaterloo.ca"
      fill_in "user[password]", with: "abcdef"
      fill_in "user[password_confirmation]", with: "abcdef"
      click_on "Create account"
      
      assert_current_path root_url
      assert_text "Welcome, Scott Pham"
    end
end