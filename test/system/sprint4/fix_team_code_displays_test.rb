require "application_system_test_case"

# Acceptance Criteria
# 1. Team's code should be displayed during team edit 

class FixTeamCodeDisplaysTest < ApplicationSystemTestCase
  setup do 
    @prof = User.new(email: 'msmucker@uwaterloo.ca', password: 'professor', password_confirmation: 'professor', first_name: 'Mark', last_name: 'Smucker', is_admin: true)
    @prof.save
    @user1 = User.new(email: 'adam@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'Adam', last_name: 'Smith', is_admin: false)
    @user1.save
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @team1 = Team.new(team_code: 'ABCDEF', team_name: 'Team 1', course: @course)
    @team1.save
    @user1.join_team_statuses.create(team: @team1, status: 1)
  end
  
  def test_display_team_code 
    visit root_url
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url

    click_on 'Manage Teams'
    assert_current_path teams_url
    
    within('#team' + @team1.id.to_s) do
      click_on 'Edit'
    end
    
    # https://www.rubydoc.info/github/jnicklas/capybara/Capybara%2FNode%2FMatchers:has_field%3F
    assert has_field?('Team code', with: @team1.team_code)
    
    click_on 'Update Team'
    
    assert_text 'Team was successfully updated'
    assert_equal('ABCDEF', @team1.team_code)
    assert_equal('Team 1', @team1.team_name)
  end
end
