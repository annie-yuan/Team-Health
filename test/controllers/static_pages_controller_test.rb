require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    # SPRINT 3 UPDATE: Seed database with default option of reports_toggled = true
    # Option.create(reports_toggled: true)
    Option.create(reports_toggled: true, admin_code: 'admin')
  end
  
  def test_should_redirect_to_login
    get root_url
    assert_response :redirect
  end

  def test_should_get_help
    prof = User.new(email: 'charles@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Smith', is_admin: true)
    prof.save
    post '/login',
        params: {email: 'charles@uwaterloo.ca', password: 'banana'}
    get '/help'
    assert_response :success
  end
  
  def test_should_render_page 
    prof = User.new(email: 'charles@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Smith', is_admin: true)
    prof.save
    user = User.new(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Smith', is_admin: false)
    user.save

    course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: prof)
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: course)
    team.save
    user.join_team_statuses.create(team: team, status: 1)

    post '/login',
        params: {email: 'charles2@uwaterloo.ca', password: 'banana'}
    
    get root_url 
    assert_response :success
  end

  def test_help_page_no_login
    get '/help'
    assert_redirected_to login_path
  end
  
  def test_help_page 
    user = User.new(email: 'charles@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Smith', is_admin: false)
    user.save!
    
    post '/login',
        params: {email: 'charles@uwaterloo.ca', password: 'banana'}
    get '/help'
    assert :success
  end
  
  def test_show_reset_password 
    get reset_password_path
    assert :success
  end

  def test_reset_password_page_no_login
    post reset_password_path, params: {existing_password: 'banana', password: 'banana2', password_confirmation: 'banana2'}
    assert_redirected_to login_path
  end
  
  def test_reset_password 
    user = User.new(email: 'charles@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Smith', is_admin: false)
    user.save!
    
    post '/login',
        params: {email: 'charles@uwaterloo.ca', password: 'banana'}
    post reset_password_path, params: {existing_password: 'banana', password: 'banana2', password_confirmation: 'banana2'}
    assert :success
    get '/logout'
    post '/login', 
        params: {email: 'charles@uwaterloo.ca', password: 'banana'}
    assert :failure
    post '/login',
        params: {email: 'charles@uwaterloo.ca', password: 'banana2'}
    assert :success
  end
  
  def test_reset_password_wrong_existing 
    user = User.new(email: 'charles@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Smith', is_admin: false)
    user.save!
    
    post '/login',
        params: {email: 'charles@uwaterloo.ca', password: 'banana'}
    post reset_password_path, params: {existing_password: 'banana3', password: 'banana2', password_confirmation: 'banana2'}
    assert_redirected_to reset_password_path
    get '/logout'
    post '/login', 
        params: {email: 'charles@uwaterloo.ca', password: 'banana2'}
    assert :failure
    post '/login',
        params: {email: 'charles@uwaterloo.ca', password: 'banana'}
    assert :success
  end
  
  def test_reset_password_wrong_new
    user = User.new(email: 'charles@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Smith', is_admin: false)
    user.save!
    
    post '/login',
        params: {email: 'charles@uwaterloo.ca', password: 'banana'}
    post reset_password_path, params: {existing_password: 'banana', password: 'bana', password_confirmation: 'bana'}
    assert_redirected_to root_url
    get '/logout'
    post '/login', 
        params: {email: 'charles@uwaterloo.ca', password: 'bana'}
    assert :failure
    post '/login',
        params: {email: 'charles@uwaterloo.ca', password: 'banana'}
    assert :success
  end
  
  def test_reset_password_wrong_confirmation
    user = User.new(email: 'charles@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Smith', is_admin: false)
    user.save!
    
    post '/login',
        params: {email: 'charles@uwaterloo.ca', password: 'banana'}
    post reset_password_path, params: {existing_password: 'banana', password: 'banana3', password_confirmation: 'banana2'}
    assert_redirected_to reset_password_path
    get '/logout'
    post '/login', 
        params: {email: 'charles@uwaterloo.ca', password: 'banana3'}
    assert :failure
    post '/login',
        params: {email: 'charles@uwaterloo.ca', password: 'banana'}
    assert :success
  end
  
  def test_should_sort_by_urgency
    prof = User.new(email: 'prof@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Prof', last_name: 'Test', is_admin: true)
    std1 = User.new(email: 'std1@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Std1', last_name: 'Test1',  is_admin: false)
    std2 = User.new(email: 'std2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Std2', last_name: 'Test2', is_admin: false)
    std3 = User.new(email: 'std3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Std3', last_name: 'Test3', is_admin: false)
    std0 = User.new(email: 'std0@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Std4', last_name: 'Test4', is_admin: false)
    course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: prof)
    high_priority_team = Team.new(team_code: 'Code1', team_name: 'Team 1', course: course)
    medium_priority_team = Team.new(team_code: 'Code2', team_name: 'Team 2', course: course)
    low_priority_team = Team.new(team_code: 'Code3', team_name: 'Team 3', course: course)
    no_feedback_team = Team.new(team_code: 'Code0', team_name: 'Team 0', course: course)

    std1.teams << high_priority_team
    std2.teams << medium_priority_team
    std3.teams << low_priority_team
    std0.teams << no_feedback_team
    high_priority_team.save
    medium_priority_team.save
    low_priority_team.save
    no_feedback_team.save
    prof.save
    std1.save
    std2.save
    std3.save
    std0.save

    high_feedback = Feedback.new(collaboration_score: 5, communication_score: 5, time_management_score: 5, 
    problem_solving_score: 5, knowledge_of_roles_score: 5, rating: 5, comments: "Good team", priority: 2, user: std1, team: low_priority_team, timestamp: Time.new(2022, 2, 3))
    medium_feedback = Feedback.new(collaboration_score: 5, communication_score: 4, time_management_score: 2, 
    problem_solving_score: 3, knowledge_of_roles_score: 1, rating: 3, comments: "Okay team", priority: 1, user: std2, team: medium_priority_team, timestamp: Time.new(2022, 2, 5))
    low_feedback = Feedback.new(collaboration_score: 1, communication_score: 1, time_management_score: 1, 
    problem_solving_score: 1, knowledge_of_roles_score: 1, rating: 1, comments: "Bad team", priority: 0, user: std3, team: high_priority_team, timestamp: Time.new(2022, 2, 2))
    high_feedback.save
    medium_feedback.save
    low_feedback.save

    post '/login',
        params: {email: prof.email, password: prof.password}
    
    get root_url 
    expected_priority_order = [high_priority_team, medium_priority_team, low_priority_team, no_feedback_team]
    assert_equal(expected_priority_order, @controller.get_teams)
  end
end
