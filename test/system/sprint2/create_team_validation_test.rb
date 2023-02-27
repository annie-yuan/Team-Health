require "application_system_test_case"
# Acceptance Criteria:
# 1. Given that a already used team code is used on the create team page,
#    I should not be able to create another team with that code

class CreateTeamValidationTest < ApplicationSystemTestCase
  # Test that Team cannot be created with a already used Team Code (1)
  def test_create_invalid_team
    # create professor 
    prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: prof)
    visit root_url
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url

    # create new team
    click_on "Manage Teams"
    find('#new-team-link').click
    
    fill_in "Team name", with: "Test Team"
    fill_in "Course code", with: "N2L3K7"
    not_created_team_code = find_field("team[team_code]").value
    created_first_team = Team.create(team_name: 'Test Team 2', team_code: not_created_team_code, course: course)
    click_on "Create Team"
    assert_text "Team code has already been taken"
  end
end