require 'test_helper'
require 'minitest/autorun'

class UserTest < ActiveSupport::TestCase

   def setup 
    @user = User.create(email: 'scott@uwaterloo.ca', password: 'password', password_confirmation: 'password', first_name: 'Scott', last_name: 'A', is_admin: false)
    @prof = User.create(email: 'charles@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'B', is_admin: true)
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
   end
   
  def test_role_function_professor
    professor = User.new(email: 'azina@uwaterloo.ca', password: 'password', password_confirmation: 'password', first_name: 'Azin', last_name: 'C', is_admin: true) 
    assert_equal('Professor', professor.role)
  end 
  
  def test_role_function_student 
    user1 = User.new(email: 'scottf@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Scott', last_name: 'B', is_admin: false)
    assert_equal('Student', user1.role)
  end 

  def test_managed_courses_student
    user1 = User.new(email: 'scottf@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Scott', last_name: 'B', is_admin: false)
    assert_nil user1.managed_courses
  end 

  def test_managed_courses_professor
    assert_equal(Course.where(id: @course.id), @prof.managed_courses.to_a)
  end 
  
  def test_name
    user1 = User.new(email: 'scottf@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Scott', last_name: 'B', is_admin: false)
    assert_equal('Scott B', user1.name)
  end 

  def test_team_names 
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save
    team2 = Team.new(team_code: 'Code2', team_name: 'Team 2', course: @course)
    team2.save
    user1 = User.new(email: 'scottf@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Scott', last_name: 'F', is_admin: false)
    user1.save
    user1.join_team_statuses.create(team: team, status: 1)
    user1.join_team_statuses.create(team: team2, status: 1)
    assert_equal(['Team 1', 'Team 2'], user1.team_names)
  end
  
  def test_course_names 
    course = Course.create(course_code: 'Calc', course_name: 'Calc', admin: @prof)
    course2 = Course.create(course_code: 'Econ', course_name: 'Econ', admin: @prof)
    team = Team.create(team_code: 'Code', team_name: 'Team 11', course: course)
    team2 = Team.create(team_code: 'Code2', team_name: 'Team 22', course: course2)
    user1 = User.create(email: 'scotta@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Scott', last_name: 'A', is_admin: false)
    user2 = User.create(email: 'scottm@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Scott', last_name: 'M', is_admin: false)
    user1.join_team_statuses.create(team: team, status: 1)
    user2.join_team_statuses.create(team: team2, status: 1)
    course.users << user1
    course2.users << user2
    course.save
    course2.save
    assert_equal(['Calc'], user1.course_names)
    assert_equal(['Econ'], user2.course_names)
  end

  def test_one_submission_no_submissions
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)

    team.save
    user1 = User.new(email: 'scottf@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Scott', last_name: 'F', is_admin: false)
    user1.save
    user1.join_team_statuses.create(team: team, status: 1)
    assert_equal([], user1.one_submission_teams)
  end
  
  def test_one_submission_existing_submissions 
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save
    user1 = User.new(email: 'scottf@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Scott', last_name: 'F', is_admin: false)
    user1.save
    user1.join_team_statuses.create(team: team, status: 1)
    save_feedback(5, 5, 5, 5, 5, 5, 'Test', user1, Time.zone.now, team, 1)
    assert_equal([team], user1.one_submission_teams)
  end
  
  # 1) As a user, I cannot create an account with a duplicate email
  test 'valid signup' do
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save
    user1 = User.new(email: 'scottf@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Scott', last_name: 'F', is_admin: false)
    user1.save
    user1.join_team_statuses.create(team: team, status: 1)
    assert user1.valid?
  end

  test 'invalid email' do
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save
    user3 = User.new(email: 'tim@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Tim', last_name: 'G', is_admin: false, teams: [team])
    assert_not user3.valid?

  end

  test 'valid email' do
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save
    user3 = User.new(email: 'tim@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Tim', last_name: 'G', is_admin: false)
    user3.save
    user3.join_team_statuses.create(team: team, status: 0)
    assert user3.valid?

  end

  test 'generate new password' do
    user1 = User.new(email: 'john@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Scott', last_name: 'F', is_admin: false)
    new_password = user1.reset_password
    assert_equal 20, new_password.length
  end

  test 'invalid signup without uwaterloo.ca email' do
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save
    user3 = User.new(email: 'tim@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Tim', last_name: 'G', is_admin: false, teams: [team])
    refute user3.valid?, 'must be UWaterloo email'
    assert_not_nil user3.errors[:email]

  end

  #test that two professors can signup
  test 'valid prof signup' do
     professor = User.new(email: 'azina@uwaterloo.ca', password: 'password', password_confirmation: 'password', first_name: 'Azin', last_name:'C', is_admin: true) 
     assert professor.valid?
  end
  
  test 'invalid signup without unique email' do
      user1 = User.new(email: 'scott@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Scott', last_name: 'F', is_admin: false)
      refute user1.valid?, 'user must have unique email'
      assert_not_nil user1.errors[:email]
  end
    
  # 4) As a user, I cannot create an account with a password less than 6 characters
  test 'invalid signup password' do
      user1 = User.new(email: 'scottf@uwaterloo.ca', password: 'apple', password_confirmation: 'apple', first_name: 'Scott', last_name: 'F', is_admin: false)
      refute user1.valid?, 'user password must have at least 6 characters'
      assert_not_nil user1.errors[:password]
  end
  #name is too long
  test 'invalid signup name' do
      user1 = User.new(email: 'scottf@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', last_name:'E', is_admin: false)
      refute user1.valid?, 'user name must have less than 40 characters'
      assert_not_nil user1.errors[:name]
  end

  # As a student, I should be able to see the number of days until a weekly rating is due,
  # and I should only see that if there are ratings due.
  def test_rating_reminders
    user = User.new(email: 'charles42@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name:'B', is_admin: false)
    user.save!

    team = Team.new(team_name: 'Hello World', team_code: 'Code', course: @course)
    team.save!
    team2 = Team.new(team_name: 'Team Name', team_code: 'Code2', course: @course)

    team2.save!
    user.join_team_statuses.create(team: team, status: 1)
    user.join_team_statuses.create(team: team2, status: 1)
    user.save!
    reminders = user.rating_reminders
    assert_equal reminders.size, 2

    # create feeedback for team
    datetime = Time.zone.now
    feedback = Feedback.new(collaboration_score: 3, communication_score: 4, time_management_score: 5, 
    problem_solving_score: 2, knowledge_of_roles_score: 1, rating: 5, comments: "This team is disorganized")
    feedback.timestamp = feedback.format_time(datetime)
    feedback.user = user
    feedback.team = team
    feedback.save! 

    # ensure that feedback created in previous week does not stop warning from displaying 
    datetime2 = DateTime.new(1990,2,3)
    feedback2 = Feedback.new(collaboration_score: 3, communication_score: 4, time_management_score: 5, 
    problem_solving_score: 2, knowledge_of_roles_score: 1, rating: 5, comments: "This team is disorganized")
    feedback2.timestamp = feedback2.format_time(datetime2)
    feedback2.user = user
    feedback2.team = team2
    feedback2.save!
    array = user.rating_reminders
    array = array.map { |team| team.team_name }
    assert_equal true, array.include?("Team Name")
    assert_equal 1, array.size
  end
end
