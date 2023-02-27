require "application_system_test_case"

# Acceptance Criteria:
# 1. Student team and name should be populated when prof edits feedback

class FeedbackFilterTest < ApplicationSystemTestCase
  setup do
    @user = User.new(email: 'test@uwaterloo.ca', password: 'asdasd', password_confirmation: 'asdasd', first_name: 'Zac', last_name: 'Brown', is_admin: false)
    @user.save
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', course: @course)
    @user.join_team_statuses.create(team: @team, status: 1)

    @team2 = Team.create(team_name: 'Test Team Two', team_code: 'TEAM02', course: @course)
    @user2 = User.new(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Ray', is_admin: false)
    @user2.save
    @user2.join_team_statuses.create(team: @team2, status: 1)

    datetime =  Time.zone.parse("2021-3-21 23:30:00")
    @feedback = save_feedback(5, 5, 5, 5, 5, 5, "This team is disorganized", @user, DateTime.civil_from_format(:local, 2021, 3, 1), @team, 0)
    @feedback3 = save_feedback(5, 4, 1, 3, 2, 3, "This team is disorganized", @user2, DateTime.civil_from_format(:local, 2021, 3, 3), @team2, 1)
  end 

  def test_filter_test_feedback_page_single_priority
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url
    click_on "Feedback & Ratings"
    find(:css, "#priority_[value='0']").set(true)
    click_on "Apply filter"
    assert_text "Zac"
    assert_no_text "Charles"
    assert_text "Test Team"
  end

  def test_filter_test_feedback_page_multiple_priority
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url
    click_on "Feedback & Ratings"
    find(:css, "#priority_[value='0']").set(true)
    find(:css, "#priority_[value='1']").set(true)
    click_on "Apply filter"
    assert_text "Zac"
    assert_text "Charles"
    assert_text "Test Team"
    assert_text "Test Team Two"
  end
end