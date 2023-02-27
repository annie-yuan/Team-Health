require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @prof = User.new(email: 'charles@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Ray', is_admin: true)
    @prof.save
    @user = User.new(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Ray', is_admin: false)
    @user.save
    
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)

    Option.create(reports_toggled: true, admin_code: 'admin')

    @team.save
    @user.join_team_statuses.create(team: @team, status: 1)
    #create new feedback from student with comment and priority of 2 (low)
    @feedback = Feedback.new(collaboration_score: 5, communication_score: 5, time_management_score: 5, 
    problem_solving_score: 5, knowledge_of_roles_score: 5, rating: 5, comments: "This team is disorganized", priority: 2)
    @feedback.timestamp = @feedback.format_time(DateTime.now)
    @feedback.user = @user
    @feedback.team = @user.teams.first
    
    @feedback.save

    @user.join_team_statuses.create(team: @team, status: 1)
  end
  
  def test_should_redirect_to_login
    get '/courses/new'
    assert_redirected_to login_path
  end

  def test_should_go_to_courses
    post('/login', params: { email: 'charles@uwaterloo.ca', password: 'banana'})
    get '/courses/new'
    assert_response :success
  end

  def test_should_not_go_to_courses_if_not_admin
    post('/login', params: { email: 'charles2@uwaterloo.ca', password: 'banana'})
    assert_raises StandardError do
      get '/courses/new'
    end
  end

  def test_should_create_course
    post('/login', params: { email: 'charles@uwaterloo.ca', password: 'banana'})
    get '/courses/new'
    assert_difference('Course.count', 1) do
      post courses_url, params: { course: { course_code: 'N2L3K8', course_name: 'Physics' } }
    end
    assert_redirected_to root_url
  end 

  def test_should_not_create_course
    post('/login', params: { email: 'charles@uwaterloo.ca', password: 'banana'})
    get '/courses/new'
    assert_difference('Course.count', 0) do
      post courses_url, params: { course: { course_name: 'Physics' } }
    end
  end 

  def test_show_course
    post('/login', params: { email: 'charles@uwaterloo.ca', password: 'banana'})
    get('/courses/'+@course.id.to_s)
    assert_response :success
  end

  def test_show_courses_filtered_current
    post('/login', params: { email: 'charles@uwaterloo.ca', password: 'banana'})
    current_course_path = '/courses/'+@course.id.to_s
    get current_course_path, params:{ feedback: {current_priority: [0,1]}}
    assert_response :success 
  end

  def test_show_courses_filtered_previous
    post('/login', params: { email: 'charles@uwaterloo.ca', password: 'banana'})
    current_course_path = '/courses/'+@course.id.to_s
    get current_course_path, params:{ feedback: {previous_priority: [0,1]}}
    assert_response :success 
  end

end
