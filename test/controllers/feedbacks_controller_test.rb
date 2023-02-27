require 'test_helper'
require 'date'

class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.new(email: 'test@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'Adam', last_name: 'Ray1', is_admin: false)
    @user2 = User.new(email: 'test2@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'Zac', last_name: 'Ray2', is_admin: false)
    @user3 = User.new(email: 'test3@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'Charles', last_name: 'Ray3', is_admin: false)
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', course: @course)
    @user.save
    @user2.save
    @user3.save
    @user.join_team_statuses.create(team: @team, status: 1)
    @user2.join_team_statuses.create(team: @team, status: 1)
    @user3.join_team_statuses.create(team: @team, status: 1)
      
    #create new feedback from student with comment and priority of 2 (low)
    @feedback = Feedback.new(collaboration_score: 5, communication_score: 5, time_management_score: 5, 
    problem_solving_score: 5, knowledge_of_roles_score: 5, rating: 5, comments: "This team is disorganized", priority: 2)
    @feedback.timestamp = @feedback.format_time(DateTime.now)
    @feedback.user = @user
    @feedback.team = @user.teams.first
    
    @feedback.save
  end

  test "should get index prof" do
    #only admin user should be able to see feedbacks
    # login user
    post('/login', params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    get feedbacks_url
    assert_response :success
  end
  
  test "should not get index student" do
    #students should now have access to the list of feedbacks. It should redirect them back to their homepage!
    post('/login', params: { email: 'test@uwaterloo.ca', password: '123456789'})
    get feedbacks_url
    assert_response :redirect
  end 
  
  test "should get new" do
    # Option.create(reports_toggled: true, admin_code: 'ADMIN')
    # login user
    post('/login', params: { email: 'test2@uwaterloo.ca', password: '123456789'})
    
    get new_feedback_url
    assert_response :success
  end

  test "should create feedback with default priority" do
    # login user
    post('/login', params: { email: 'test3@uwaterloo.ca', password: '123456789'})
    
    assert_difference('Feedback.count') do
        #not passing in a priority value results in default value of 2, which represents low priority
        post "/teams/#{@team.id}/feedbacks", params: { feedback: { comments: "test comment", collaboration_score: 5, communication_score: 5, time_management_score: 5, 
        problem_solving_score: 5, knowledge_of_roles_score: 5, rating: 5} }
    end
    assert_redirected_to root_url
  end
  
  test "should create feedback with selected priority" do
    # login user
    post('/login', params: { email: 'test3@uwaterloo.ca', password: '123456789'})
    
    assert_difference('Feedback.count') do
        #student selects a priority of 0, meaning it's urgent
        post "/teams/#{@team.id}/feedbacks", params: { feedback: { comments: "test comment", collaboration_score: 5, communication_score: 5, time_management_score: 5, 
        problem_solving_score: 5, knowledge_of_roles_score: 5, rating: 5, priority: 0 } }
    end
    assert_redirected_to root_url
  end

  test "should show feedback" do
    # login professor
    post('/login', params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    get feedback_url(@feedback)
    assert_response :success
  end

  test "cannot created multiple feedback in same week" do
    # login professor
    post('/login', params: { email: 'test@uwaterloo.ca', password: '123456789'})
    assert_no_difference('Feedback.count') do
      post "/teams/#{@team.id}/feedbacks", params: { feedback: { comments: "test comment", collaboration_score: 5, communication_score: 5, time_management_score: 5, 
      problem_solving_score: 5, knowledge_of_roles_score: 5, rating: 5, priority: 0 } }
    end
    assert_redirected_to root_url
  end

  test "try to create wrong feedback" do
    # login professor
    post('/login', params: { email: 'test3@uwaterloo.ca', password: '123456789'})
    assert_no_difference('Feedback.count') do
      post feedbacks_url, params: { feedback: { comments: "test comment", communication_score: 5, time_management_score: 5, 
      problem_solving_score: 5, knowledge_of_roles_score: 5, rating: 5, priority: 0 } }
    end
  end


  test "should flash error when trying to filter" do
    # login professor
    post('/login', params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    get feedbacks_url, params: { priority: [1]}
    assert_equal "There are no feedbacks with chosen priority.", flash[:error] 
  end

  test "should show filtered error when trying to filter" do
    # login professor
    post('/login', params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    get feedbacks_url, params: { priority: [0,1]}
    assert_response :success 
  end

  

end
