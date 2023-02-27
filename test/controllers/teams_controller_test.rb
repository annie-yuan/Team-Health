require 'test_helper'

class TeamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Option.create(reports_toggled: true)
    # create test admin
    @prof = User.new(email: 'charles@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Ray', is_admin: true)
    @prof.save
    @user = User.new(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Ray', is_admin: false)
    @user.save
    
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    @team.save

    @user.join_team_statuses.create(team: @team, status: 0)
    # login user
    post('/login', params: { email: 'charles@uwaterloo.ca', password: 'banana'})
      assert_redirected_to root_url
  end

  test "should add user" do
    team2 = Team.create(team_code: 'Code2', team_name: 'Team 2', course: @course)
    user2 = User.new(email: 'cathy@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Cathy', last_name: 'Pham', is_admin: false)
    user2.save
    post("/teams/#{team2.id}/users", params: { user_email: user2.email})
    assert_includes(team2.users, user2)
    assert_includes(@course.users, user2)
  end

  test "should not add user not sign up" do
    course = Course.create(course_name: 'Psych', course_code: 'N2L3K9', admin: @prof)
    team2 = Team.create(team_code: 'Code2', team_name: 'Team 2', course: course)
    post("/teams/#{team2.id}/users", params: { user_email: "not_signed_up@uwaterloo.ca"})
    assert_empty(team2.users)
    assert_empty(course.users)
  end

  test "should not add user already in team" do
    course = Course.create(course_name: 'Psych', course_code: 'N2L3K9', admin: @prof)
    team2 = Team.create(team_code: 'Code2', team_name: 'Team 2', course: course)
    user2 = User.new(email: 'cathy@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Cathy', last_name: 'Pham', is_admin: false)
    user2.save
    user2.join_team_statuses.create(team: team2, status: 0)
    post("/teams/#{team2.id}/users", params: { user_email: user2.email})
    assert_equal(1, team2.users.count)
  end
  
  test "should not add user already in another team in a course" do
    course = Course.create(course_name: 'Psych', course_code: 'N2L3K9', admin: @prof)
    team2 = Team.create(team_code: 'Code2', team_name: 'Team 2', course: course)
    team3 = Team.create(team_code: 'Code3', team_name: 'Team 3', course: course)
    user2 = User.new(email: 'cathy@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Cathy', last_name: 'Pham', is_admin: false)
    user2.save
    user2.join_team_statuses.create(team: team2, status: 0)
    post("/teams/#{team3.id}/users", params: { user_email: user2.email})
    assert_equal(0, team3.users.count)
  end

  test "should get index" do
    get teams_url
    assert_response :success
  end

  test "should get new" do
    get new_team_url
    assert_response :success
  end

  test "should create team" do
    assert_difference('Team.count', 1) do
      post teams_url, params: { team: { team_code: 'Code2', team_name: 'asdf', course_code: 'N2L3K7' } }
    end

    assert_redirected_to team_url(Team.last)
  end

  test "should show team" do
    save_feedback(5, 5, 5, 5, 5, 5, 'test', @user, Time.zone.now, @team, 2)
    
    get team_url(@team)
    assert_response :success
  end
  
  def test_should_not_show_team 
    get '/logout'
    
    user2 = User.new(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Ray', is_admin: false)
    user2.save
    
    post('/login', params: { email: 'charles3@uwaterloo.ca', password: 'banana'})
    get team_url(@team)
    assert_redirected_to root_url
  end

  test "should get edit" do
    get edit_team_url(@team)
    assert_response :success
  end

  test "should get confirm delete team" do
    get team_confirm_delete_url(@team)
    assert_response :success
  end

  test "should get confirm delete user from team" do
    get('/teams/'+@team.id.to_s+'/confirm_delete_user_from_team', params: { user_id: @user.id, team_id: @team.id})
    assert_response :success
  end

  test "should update team" do
    patch team_url(@team), params: { team: { team_code: @team.team_code, team_name: @team.team_name } }
    assert_redirected_to teams_url
  end

  test "should update team code" do
    patch team_url(@team), params: { team: { team_code: @team.team_code} }
    assert_response :success
  end

  test "should destroy team no feedback" do
    assert_difference('Team.count', -1) do
      delete team_url(@team)
    end

    assert_redirected_to teams_url
  end
  
  def test_student_cannot_destroy_team 
    get('/logout')
    post('/login', params: { email: 'charles2@uwaterloo.ca', password: 'banana'})
    
    assert_difference('Team.count', 0) do
      delete team_url(@team)
    end

    assert_redirected_to root_url
  end
  
  def test_should_destroy_team_with_feedback
    team2 = Team.new(team_code: 'Code2', team_name: 'Team 2', course: @course)
    team2.save
    
    user2 = User.new(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Ray', is_admin: false)
    user2.teams = [team2]
    user2.save
    
    feedback = save_feedback(5, 5, 5, 5, 5, 5, "This team is disorganized", @user, DateTime.civil_from_format(:local, 2021, 3, 1), @team, 2)
    feedback2 = save_feedback(5, 4, 1, 3, 2, 3, "This team is disorganized", @user, DateTime.civil_from_format(:local, 2021, 3, 3), @team, 2)
    feedback3 = save_feedback(5, 4, 1, 3, 2, 3, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team2, 2)

    assert_difference('Team.count', -1) do 
      delete team_url(@team)
    end 

    assert_equal(1, Feedback.count)
    Feedback.all.each do |feedback|
      assert_equal(feedback3, feedback)
    end
  end
    
  def test_create_team_invalid_code
    assert_no_difference 'Team.count' do
      post '/teams', 
        params: {team: {team_name: "Team 3", team_code: 'qwertyuiopasdfghjklzxcvbnmq', course_code: 'N2L3K7'}}
      get new_team_url
    end
  end
    
  def test_create_team_invalid_name
    assert_no_difference 'Team.count' do
      post '/teams', 
        params: {team: {team_name: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", team_code: 'qwerty', course_code: 'N2L3K7'}}
      get new_team_url
    end
  end

  def test_should_not_create_team
    post('/login', params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    assert_difference('Team.count', 0) do
      post '/teams',  params: { team: { team_name: 'test', team_code: 'NLK908', course:'N2L3K8'}}
    end
    assert_redirected_to root_path
  end 

  def test_create_team_blank_code
    assert_no_difference 'Team.count' do
      post '/teams', 
        params: {team: {team_name: "Team 3", team_code: '', course_code: 'N2L3K7'}}
      get new_team_url
    end
  end
    
  def test_create_team_blank_name
    assert_no_difference 'Team.count' do
      post '/teams', 
        params: {team: {team_name: "", team_code: 'qwerty', course_code: 'N2L3K7'}}
      get new_team_url
    end
  end

  def test_create_team_duplicate_name
    assert_no_difference 'Team.count' do
      post '/teams', 
        params: {team: {team_name: "", team_code: 'qwerty', course_code: 'N2L3K7'}}
      get new_team_url
    end
  end
  
  def test_help_page
    get '/team_view/help'
    assert :success
  end

  #Also test downcase
  def test_create_team_duplicate_code
    assert_no_difference 'Team.count' do
      post '/teams', 
        params: {team: {team_name: "Team 1", team_code: 'random', course_code: 'N2L3K7'}}
      get new_team_url
    end
  end

  test "should allow student access to their teams view" do
    # logout admin
    get '/logout'
    # login to user account
    post('/login', params: { email: 'charles2@uwaterloo.ca', password: 'banana'})

    get team_url(@team)
    assert_response :success
    post('/login', params: { email: 'charles@uwaterloo.ca', password: 'banana'}) 
  end
  
  def test_delete_user_from_team_as_prof
    post(login_path, params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    post team_remove_user_from_team_path(user_id: @user.id, team_id: @team.id)
    assert_equal([], @team.users)
  end
  
  def test_delete_user_from_team_as_student
    post(login_path, params: { email: 'charles2@uwaterloo.ca', password: 'banana'})
    post team_remove_user_from_team_path(user_id: @user.id, team_id: @team.id)
    assert_not_equal([], @team.users)
  end

end
