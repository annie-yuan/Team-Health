require "application_system_test_case"

# Acceptance Criteria:
# 1: As a professor, I should be able to see colored indicators for team summary and detailed views
# 2: As a student, I should be able to see colored indicators for team summary and detailed views

class VisualIndicatorsTest < ApplicationSystemTestCase
  setup do
    @prof = User.create(email: 'charles@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Test', is_admin: true)
    
    @user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Test1', is_admin: false)
    @user1.save!
    @user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Test2', is_admin: false)
    @user2.save!
    @user3 = User.create(email: 'charles4@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles3', last_name: 'Test3', is_admin: false)
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    @team.save!     
    @user1.join_team_statuses.create(team: @team, status: 1)
    @user2.join_team_statuses.create(team: @team, status: 1)

    #10, 2, 5
    travel_to Time.new(2021, 02, 21, 06, 04, 44)
    @feedback = save_feedback(5,5,5,5,5,5, "This team is disorganized", @user1, DateTime.civil_from_format(:local, 2021, 2, 16), @team, 2)
    @feedback2 = save_feedback(1,1,1,1,1,1, "This team is disorganized", @user2, DateTime.civil_from_format(:local, 2020, 12, 17), @team, 2)
    @feedback3 = save_feedback(3,3,3,3,3,3, "This team is disorganized", @user1, DateTime.civil_from_format(:local, 2021, 1, 18), @team, 2)
  end 
  
  def test_student_view 
    visit root_url 
    login 'charles2@uwaterloo.ca', 'banana'
    
    within('#' + @team.id.to_s) do
      assert find('.dot-grey')
    end
    
    click_on 'View Historical Data'
    
    assert find('.dot-red')
    assert find('.dot-yellow')
  end
  
  def test_professor_view 
    visit root_url 
    login 'charles@uwaterloo.ca', 'banana'
    click_on 'Math'
    within('#' + @team.id.to_s) do 
      assert find('.dot-grey')
    end 
    
    click_on 'Details'
    
    assert find('.dot-red')
    assert find('.dot-yellow')
  end
end
