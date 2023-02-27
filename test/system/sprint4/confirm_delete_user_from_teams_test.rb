require "application_system_test_case"

class ConfirmDeleteUserFromTeamsTest < ApplicationSystemTestCase
  setup do 
    @prof = User.new(email: 'msmucker@uwaterloo.ca', password: 'professor', password_confirmation: 'professor', first_name: 'Mark', last_name: 'Smucker', is_admin: true)
    @prof.save
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @user1 = User.new(email: 'adam@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'Adam', last_name: 'Smith', is_admin: false)
    @user1.save

    @team1 = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    @team1.save
    @user1.join_team_statuses.create(team: @team1, status: 1)
  end
    
  def test_get_confirm_message_when_deleting_user_from_team
    visit root_url
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url

    click_on 'Manage Teams'
    assert_current_path teams_url 
    
    within('#team' + @team1.id.to_s) do
      assert_text 'Team 1'
      assert_text 'Adam'
      click_on 'Show'
    end

    assert_text 'Adam'
    click_on 'Remove User From Team'
   
    assert_equal 1, Team.count
    #professor and student
    assert_equal 2, User.count
      
    assert_equal([@user1], @team1.users)
   
    assert_text 'Confirm Remove Adam Smith from Team 1'
    click_on 'Remove User'
      
    assert_current_path root_url
    assert_text 'User removed successfully.'
    assert_no_text 'Adam'
    @team = Team.find_by team_code: 'Code'
    assert_equal([], @team.users)
  end
end
