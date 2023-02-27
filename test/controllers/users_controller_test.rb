require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    Option.destroy_all
    Option.create(reports_toggled: true, admin_code: 'ADMIN')
    # create test user
    @user = User.new(email: 'charles@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Ray', is_admin: false)
    @user.save
    @user2 = User.new(email: 'test2@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'Zac', last_name: 'Ray2', is_admin: false)
    @user2.save
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @team = Team.new(team_code: 'Code2', team_name: 'Team 1', course: @course)
    @team.save
    @user.join_team_statuses.create(team: @team, status: 1)
    @user2.join_team_statuses.create(team: @team, status: 1)
  end
  
  def test_create_user
    # login user
    team = Team.new(team_code: 'Code', team_name: 'Team 2', course: @course)
    team.save  
    
    post '/users', 
      params: {user: {email: 'scott@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Scott', last_name: 'Smith'}}
    assert_redirected_to root_url
  end
  
  def test_create_prof 
    assert_difference('User.count', 1) do 
      post '/users', 
        params: {user: {email: 'prof@uwaterloo.ca', first_name: 'Professor', last_name: 'Test', admin_code: 'ADMIN', password: 'professor', password_confirmation: 'professor'}}
      assert_redirected_to root_url 
    end 
    
    prof = User.find_by(email: 'prof@uwaterloo.ca')
    assert(prof.is_admin)
  end

  def test_create_prof_invalid_admin_code
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'prof@uwaterloo.ca', first_name: 'Professor', last_name: 'Test', admin_code: 'ADMIN2', password: 'professor', password_confirmation: 'professor'}}
      assert_template :new
    end 
  end
  
  # 04/09/2021 for consistency with team code, admin code now case sensitive
  #def test_create_prof_insensitive_code 
  #  assert_difference('User.count', 1) do 
  #    post '/users', 
  #      params: {user: {email: 'prof@gmail.com', name: 'Professor', team_code: 'admIN', password: 'professor', password_confirmation: 'professor'}}
  #    assert_redirected_to root_url 
  #  end 
  #  
  #  prof = User.find_by(email: 'prof@gmail.com')
  #  assert(prof.is_admin)
  #end
    
  def test_create_user_missing_name
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@uwaterloo.ca', password: 'banana', password_confirmation: 'banana'}}
      assert_template :new
    end
  end
    
  def test_create_user_invalid_name
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', last_name: 'test', user_id: '1010'}}
      assert_template :new
    end
  end
  
  def test_create_user_missing_email
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: { password: 'banana', password_confirmation: 'banana', first_name: 'Scott', last_name: 'Smith'}}
      assert_template :new
    end
  end
  #also checks email converts to lowercase
  def test_create_user_non_unique_email
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'Charles@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Scott', last_name: 'Smith'}}
      assert_template :new
    end
  end
    
  def test_create_user_non_valid_email
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'Charles', password: 'banana', password_confirmation: 'banana', first_name: 'Scott', last_name: 'Smith'}}
      assert_template :new
    end
  end
  
  def test_create_user_missing_password
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@uwaterloo.ca', password_confirmation: 'banana', first_name: 'Scott', last_name: 'Smith'}}
      assert_template :new
    end
  end
  
  def test_create_user_missing_password_confirmation
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@uwaterloo.ca', password: 'banana', first_name: 'Scott', last_name: 'Smith'}}
      assert_template :new
    end
  end

  def test_create_user_nonmatching_passwords
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@uwaterloo.ca', password: 'banana', password_confirmation: 'banana2', first_name: 'Scott', last_name: 'Smith'}}
      assert_template :new
    end
  end
  
    
  def test_get_signup
    get '/signup'
    assert_response :success
    assert_select 'h1', 'Sign up!'
  end
  

  test "should get index" do
    post('/login', params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    get users_url
    assert_response :success
  end

  def test_new_redirect
    post '/login',
        params: {email: 'charles@uwaterloo.ca', password: 'banana'}
    get '/signup'
    assert_redirected_to root_url
  end

  test "should show user" do
    post('/login', params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    get user_url(@user)
    assert_response :success
  end

  test "should get edit" do
    post('/login', params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    get edit_user_url(@user)
    assert_response :success
  end

  def test_show_student_edit_page 
    post('/login', params: { email: 'charles@uwaterloo.ca', password: 'banana'})
    get edit_user_url(@user)
    assert_response :success
  end

  test "student can update name" do
    post('/login', params: { email: 'charles@uwaterloo.ca', password: 'banana'})
    patch user_url(@user), params: { user: { first_name: 'Charlie', last_name: 'Bob'} }
    assert_redirected_to root_url
  end

  test "student should be able to edit name" do
    post('/login', params: { email: 'charles@uwaterloo.ca', password: 'banana'})
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    post('/login', params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    patch user_url(@user), params: { user: { email: @user.email, name: @user.name, password: @user.password, password_confirmation: @user.password_confirmation } }
    assert_redirected_to root_url
  end

  def test_delete_student_as_prof
    @generated_code = Team.generate_team_code
    @team = Team.create(team_name: 'Test Team', team_code: @generated_code.to_s, course: @course)
    @bob = User.create(email: 'bob@uwaterloo.ca', first_name: 'Bob', last_name: 'Smith', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.join_team_statuses.create(team: @team, status: 1)
    
    post(login_path, params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    delete(user_path(@bob.id))
    
    User.all.each { |user| 
        assert_not_equal(@bob.name, user.name)
    }
  end
  
  def test_delete_admin_as_prof
    @ta = User.create(email: 'amir@uwaterloo.ca', first_name: 'Amir', last_name: 'Badr', is_admin: true, password: 'password', password_confirmation: 'password')
    
    post(login_path, params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    delete(user_path(@ta.id))
    
    assert_not_nil(User.find_by(email: 'amir@uwaterloo.ca'))
  end

  def test_delete_prof_as_prof
    @ta = User.create(email: 'amir@uwaterloo.ca', first_name: 'Amir', last_name: 'Badr', is_admin: true, password: 'password', password_confirmation: 'password')
    
    post(login_path, params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    delete(user_path(@prof.id))
    
    assert_not_nil(User.find_by(email: 'msmucker@uwaterloo.ca'))
  end
  
  test "should destroy user" do
    post('/login', params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    assert_difference('User.count', -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end

  def test_delete_as_student
    @bob = User.create(email: 'bob@uwaterloo.ca', first_name: 'Bob', last_name: 'Smith', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    post('/login', params: { email: 'bob@uwaterloo.ca', password: 'testpassword'})

    delete(user_path(@prof.id))
    assert_not_nil(User.find_by(email: 'charles@uwaterloo.ca'))
  end

  def test_delete_as_student_not_admin
    @bob = User.create(email: 'bob@uwaterloo.ca', first_name: 'Bob', last_name: 'Smith', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    post('/login', params: { email: 'bob@uwaterloo.ca', password: 'testpassword'})

    assert_difference('User.count', 0) do
      delete user_url(@user)
    end

    assert_not_nil(User.find_by(email: 'charles@uwaterloo.ca'))
    assert_redirected_to root_url
  end

  test "should get confirm delete user" do
    post('/login', params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    get('/users/'+@user.id.to_s+'/confirm_delete', params: { user_id: @user.id})
    assert_response :success
  end

end
