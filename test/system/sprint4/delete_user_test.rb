require "application_system_test_case"

# Acceptance Criteria
# 1. As a professor, I have the ability to delete a student user from the app
# 2. As a professor, I have the ability to delete an admin user from the app
# 3. As a student, I do not have the ability to delete any user from the app

class DeleteUserTest < ApplicationSystemTestCase
  setup do
    Option.create(reports_toggled: true, admin_code: 'ADMIN')
    @generated_code = Team.generate_team_code
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'password', password_confirmation: 'password')
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', course: @course)
  end
  
  #(1)
  def test_delete_student_as_prof
    Option.destroy_all
    Option.create(reports_toggled: true, admin_code: 'ADMIN')
    @bob = User.create(email: 'bob@uwaterloo.ca', first_name: 'Bob', last_name: 'Smith', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.join_team_statuses.create(team: @team, status: 1)
    @team.course.users << @bob
    visit root_url 
    # Login as professor
    login 'msmucker@uwaterloo.ca', 'password'
    
    click_on "Manage Users"
    
    within('#user' + @bob.id.to_s) do
      assert_text @bob.email
      assert_text @bob.name
      click_on 'Delete User'
    end
    
    assert_current_path user_confirm_delete_path(@bob)
    click_on "Delete User"

    assert_text "User was successfully destroyed."
    
     User.all.each { |user| 
        assert_not_equal(@bob.name, user.name)
    }
  end
  
  
  #(2)
  # def test_cannot_delete_admin_as_prof
  #   Option.destroy_all
  #   Option.create(reports_toggled: true, admin_code: 'ADMIN')
  #   @ta = User.create(email: 'amir@uwaterloo.ca', first_name: 'Amir', last_name: 'A', is_admin: true, password: 'password', password_confirmation: 'password')
    
  #   visit root_url 
  #   # Login as professor
  #   login 'msmucker@uwaterloo.ca', 'password'

  #   click_on "Manage Users"
    
  #   within('#user' + @ta.id.to_s) do
  #     assert_text @ta.email
  #     assert_text @ta.name
  #     assert_no_text 'Delete User'
  #   end
  # end
  
    #(3)
  def test_delete_as_student
    Option.destroy_all
    Option.create(reports_toggled: true, admin_code: 'ADMIN')
    @bob = User.create(email: 'bob@uwaterloo.ca', first_name: 'Bob', last_name: 'Smith', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.join_team_statuses.create(team: @team, status: 1)

    visit root_url 
    # Login as professor
    login 'bob@uwaterloo.ca', 'testpassword'

    visit users_path
    
    assert_current_path root_url
    assert_text "You do not have Admin permissions."
  end

end
