require "application_system_test_case"

# Acceptance Criteria
# 1. As a user, I should be able to view a help page regarding feedback results
#    for team summary view
# 2. As a user, I should be able to view a help page regarding feedback results for detailed
#    team view

class HelpPageTest < ApplicationSystemTestCase
  setup do
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @course = Course.create(course_name: 'Math', course_code:'N2L3K7', admin: @prof)
  end
  
  # (1)
  def test_home_help
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    click_on 'Help'
    assert_text 'Help page'
  end

  # (2)
  def test_teams_view_help
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!
    user = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Test1', is_admin: false)
    user.save!
    team.join_team_statuses.create(user: user, status: 1)
    feedback = Feedback.new(rating: 3, collaboration_score: 1, communication_score: 2, time_management_score: 3, 
      problem_solving_score: 4, knowledge_of_roles_score: 4, priority: 2, comments: "This team is disorganized")
    feedback.timestamp = feedback.format_time(DateTime.now)
    feedback.user = user
    feedback.team = user.teams.first
    feedback.save!

    visit root_url
    login 'msmucker@uwaterloo.ca', 'professor' 
    click_on 'Math'
    click_on 'Details'
    click_on 'Help'
    assert_text "Team's Individual Feedback"
  end
end