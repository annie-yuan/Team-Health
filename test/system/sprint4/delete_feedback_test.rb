require "application_system_test_case"


class DeleteFeedbackTest < ApplicationSystemTestCase
  setup do 
    @prof = User.new(email: 'msmucker@uwaterloo.ca', password: 'professor', password_confirmation: 'professor', first_name: 'Mark', last_name: 'Smucker', is_admin: true)
    @prof.save
    @user = User.new(email: 'adam@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'Adam', last_name: 'Smith', is_admin: false)
    @user.save
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    @team.save
    @user.join_team_statuses.create(team: @team, status: 1)

    #create new feedback from student with comment and priority of 2 (low)
    @feedback = Feedback.new(rating: 4, collaboration_score: 1, communication_score: 2, time_management_score: 5,
       problem_solving_score: 3, knowledge_of_roles_score: 2,comments: "This team is disorganized", priority: 2)
    @feedback.timestamp = @feedback.format_time(DateTime.now)
    @feedback.user = @user
    @feedback.team = @user.teams.first
    
    @feedback.save
  end 
  
  def test_delete_feedback
    visit root_url
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url
    click_on "Feedback & Ratings"
    assert_no_text "Delete Feedback"
  end 

  def test_prof_cannot_edit_feedback
    visit root_url
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url
    click_on "Feedback & Ratings"
    assert_no_text "Edit"
  end
end
