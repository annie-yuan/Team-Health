require "application_system_test_case"

class AdminTeamFieldTest < ApplicationSystemTestCase

  setup do
    prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: prof)
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Test1', is_admin: false)
    user1.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: course)
    team.save!
    user1.join_team_statuses.create(team: team, status: 1)
    course.users << user1
  end

  def test_not_admin_does_show_team_field

    # log professor in
    visit root_url
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url
    
    click_on 'Manage Users'
    assert_current_path users_url

    #student is listed first by name, alphabetically
    click_link("Show", :match => :first)    
    assert_text "Team:", count: 1

  end

  def test_admin_does_not_show_team_field

    # log professor in
    visit root_url
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url
    click_on "Account"
    assert_text "Team:", count: 0

  end
end
