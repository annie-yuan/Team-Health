require "application_system_test_case"

# Acceptance Criteria: 
# 1. When I submit the feedback form, all the input data should be added to
#    the database
# 2. When I select the rating dropdown, all the appropriate ratings should
#    appear
# 3. When I submit the feedback form, the data shold be associated with my 
#    team in the database

class CreateFeedbackFormUnvalidatedsTest < ApplicationSystemTestCase
  setup do
    # create prof, team, and user
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', course: @course)
    @bob = User.create(email: 'bob@uwaterloo.ca', first_name: 'Bob', last_name: 'Smith', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.join_team_statuses.create(team: @team, status: 1)
  end
  
  # Test that feedback can be added using correct form (1, 2)
  def test_add_feedback 
    visit root_url 
    login 'bob@uwaterloo.ca', 'testpassword'    
    
    click_on "Submit for"
    assert_current_path "/teams/#{@team.id}/feedbacks"
    assert_text "Your Current Team: Test Team"
    
    select 5, :from => "Collaboration score"
    select 5, :from => "Communication score"
    select 5, :from => "Time management score"
    select 5, :from => "Problem solving score"
    select 5, :from => "Knowledge of roles score"
    select "High", from: "Priority"
    fill_in "feedback_comments", with: "This week has gone okay."
    click_on "Create Feedback"
    
    assert_current_path root_url
    
    Feedback.all.each{ |feedback| 
      assert_equal(5 , feedback.rating)
      assert_equal(0 , feedback.priority)
      assert_equal('This week has gone okay.', feedback.comments)
      assert_equal(@bob, feedback.user)
      assert_equal(@team, feedback.team)
    }
  end
  
  # Test that feedback that is added can be viewed (1, 3)
  def test_view_feedback 
    feedback = Feedback.new(rating: 4, collaboration_score: 1, communication_score: 2, time_management_score: 5, problem_solving_score: 3, knowledge_of_roles_score: 2, comments: "This team is disorganized", priority: 0)
    datetime = Time.current
    feedback.timestamp = feedback.format_time(datetime)
    feedback.user = @bob
    feedback.team = @bob.teams.first
    feedback.save
    
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    
    click_on "Math"
    click_on "Details"
    assert_current_path team_url(@team)
    assert_text "This team is disorganized"
    assert_text "4"
    assert_text "Urgent"
    assert_text "Test Team"
    assert_text datetime.strftime("%Y-%m-%d %H:%M")
  end
end
