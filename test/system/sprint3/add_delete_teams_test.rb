require "application_system_test_case"

# Acceptance Criteria
# 1. As a professor, I should be able to delete/disband a team
# 2. As a student, I should not be able to delete any team

class AddDeleteTeamsTest < ApplicationSystemTestCase
  setup do 
    @prof = User.new(email: 'charles@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Test', is_admin: true)
    @prof.save
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @user1 = User.new(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Test2', is_admin: false)
    @user1.save

    @team1 = Team.new(team_code: 'Code', team_name: 'Team 1')
    @team1.course = @course
    @team1.save
    @user1.join_team_statuses.create(team: @team1, status: 1)

    @team2 = Team.new(team_code: 'Code2', team_name: 'Team 2')
    @team2.course = @course
    @team2.save
    
    @user2 = User.new(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles3', last_name: 'Test3', is_admin: false)
    @user2.save
    @user2.join_team_statuses.create(team: @team2, status: 1)
    
    @feedback = save_feedback(5,5,5,5,5,5, "This team is disorganized", @user, DateTime.civil_from_format(:local, 2021, 3, 1), @team1, 2)
    @feedback2 = save_feedback(5,5,5,5,5,5, "This team is disorganized", @user, DateTime.civil_from_format(:local, 2021, 3, 3), @team1, 2)
    @feedback3 = save_feedback(5,5,5,5,5,5, "This team is disorganized", @user2, DateTime.civil_from_format(:local, 2021, 3, 3), @team2, 2)
  end 
  
  # (1)
  def test_delete_team_professor 
    visit root_url
    login 'charles@uwaterloo.ca', 'banana'
    assert_current_path root_url
    
    click_on 'Manage Teams'
    assert_current_path teams_url 
    
    within('#team' + @team1.id.to_s) do
      assert_text 'Team 1'
      click_on 'Delete Team'
    end
    
    assert_current_path team_confirm_delete_path(@team1)
    assert_text "Confirm Delete #{@team1.team_name}"
    click_on "Delete Team"
    
    assert_current_path teams_url 
    assert_text "Team was successfully destroyed"
    assert_no_text "Team 1"
    assert_text "Team 2"
  end
  
  #(2)
  def test_delete_team_student 
    visit root_url
    login 'charles2@uwaterloo.ca', 'banana'
    assert_current_path root_url
    
    assert_no_text 'Manage Teams'
    
    # Testing of security of path (e.g. cannot directly send DELETE request) 
    # included in controller
  end
end
