  require 'test_helper'

  class AccountsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = User.new(email: 'test@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'Adam', last_name: 'Ray1', is_admin: false)
    @user2 = User.new(email: 'test2@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'Zac', last_name: 'Ray2', is_admin: false)
    @user3 = User.new(email: 'test3@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'Charles', last_name: 'Ray3', is_admin: false)
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', course: @course)
    @user.teams << @team
    @user.save
    @user2.teams << @team
    @user2.save
    @user3.teams << @team
    @user3.save
  end    

  test "should get index" do
    post('/login', params: { email: 'msmucker@uwaterloo.ca', password: 'professor' })
    get accounts_url
    assert_response :success
  end

end