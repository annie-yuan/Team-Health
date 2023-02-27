require 'test_helper'
require 'date'
class TeamTest < ActiveSupport::TestCase
    include FeedbacksHelper
    
    setup do
        @prof = User.create(email: 'charles@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Dion', is_admin: true)
        @course = Course.create(course_name: 'Math', course_code: 'N2L3K7')
    end

    def test_unique_team_code_admin
      Option.destroy_all
      Option.create(reports_toggled: true, admin_code: 'admin')
      
      team2 = Team.new(team_code: 'admin', team_name: 'Team 2', course: @course)
      assert_not team2.valid?
    end 
  
    def test_add_students
        # create test admin
        user = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Ray', is_admin: false)
        user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Ray', is_admin: false)

        team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
        team.save
        user.join_team_statuses.create(team: team, status: 1)
        user2.join_team_statuses.create(team: team, status: 1)
        assert_equal(JoinTeamStatus.count, 2)
    end

    def test_create_team_invalid_team_code
        team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
        team.save!
        # try creating team with another team with same team code
        # test case insensitive
        team2 = Team.new(team_code: 'code', team_name: 'Team 2', course: @course)
        assert_not team2.valid?
    end

    def test_create_team_blank_team_code
        team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
        team.save!
        # try creating team with blank code
        team2 = Team.new(team_name: 'Team 2', course: @course)
        assert_not team2.valid?
    end
    
    def test_create_team_blank_team_name
        team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
        team.save!
        # try creating team with blank name
        team2 = Team.new(team_code: 'Code2', course: @course)
        assert_not team2.valid?
    end
    
    def test_add_students_to_team
        user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Ray', is_admin: false)
        user1.save!
        team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
        team.save!
        assert_difference("team.users.count", + 1) do
            team.users << user1
            team.save!
        end
    end

  def test_create_user_invalid_team_duplicate
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!
    # try creating team with another team with same team code
    team2 = Team.new(team_code: 'Code', team_name: 'Team 2', course: @course)
    assert_not team2.valid?
  end
  
  def test_create_user_invalid_team_code
    # too long of a code
    team2 = Team.new(team_code: 'qwertyuiopasdfghjklzxcvbnmq', team_name: 'Team 2', course: @course)
    assert_not team2.valid?
  end

  def test_create_user_invalid_team_name
    # too long of a name
    team2 = Team.new(team_code: 'qwerty', team_name: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', course: @course)
    assert_not team2.valid?
  end
    
  def test_add_students_to_team
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Ray', is_admin: false)
    user1.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!
    assert_difference("team.users.count", + 1) do
      user1.join_team_statuses.create(team: team, status: 1)
    end
  end

  def test_get_student_names
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Ray1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Ray2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!
    user1.join_team_statuses.create(team: team, status: 1)
    user2.join_team_statuses.create(team: team, status: 1)
    students = team.student_names
    students.sort!
    assert_equal ['Charles1', 'Charles2', 'Ray1', 'Ray2'], students
  end
  
  def test_feedback_by_period_no_feedback 
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save! 
    
    assert_nil(team.feedback_by_period)
  end
  
  def test_feedback_by_period_one_period
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Ray', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Ray', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code2', team_name: 'Team 2', course: @course)
    team.save!     
    
    feedback = save_feedback(5, 5, 5, 5, 5, 5, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2)
    feedback2 = save_feedback(5, 4, 3, 2, 1, 3, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2)
    
    periods = team.feedback_by_period 
    assert_equal({year: 2021, week: 9}, periods[0][0])
    assert_includes( periods[0][1], feedback )
    assert_includes( periods[0][1], feedback2 )
    assert_equal( 2, periods[0][1].length )
  end
  
  def test_feedback_by_period_multi_period
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Ray', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Ray', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code2', team_name: 'Team 2', course: @course)
    team.save!     
    
    feedback = save_feedback(5, 5, 5, 5, 5, 5, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2)
    feedback2 = save_feedback(4, 3, 2, 1, 5, 3, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2)
    feedback3 = save_feedback(4, 4, 4, 4, 4, 4, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 2, 15), team, 2)
    feedback4 = save_feedback(3, 3, 3, 3, 3, 3, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 2, 16), team, 2)
    
    periods = team.feedback_by_period 
    assert_equal({year: 2021, week: 9}, periods[0][0])
    assert_equal({year: 2021, week: 7}, periods[1][0])
    assert_includes( periods[0][1], feedback )
    assert_includes( periods[0][1], feedback2 )
    assert_includes( periods[1][1], feedback3 )
    assert_includes( periods[1][1], feedback4 )
    assert_equal( 2, periods[0][1].length )
    assert_equal( 2, periods[1][1].length )
  end
  
  def test_find_priority_weighted_team_summary_high_status
    week_range = week_range(2021, 7)
    
    user1 = User.create(email: 'adam1@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'adam1', last_name: 'Ray', is_admin: false)
    user1.save!
    user2 = User.create(email: 'adam2@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'adam2', last_name: 'Ray', is_admin: false)
    user2.save!
    user3 = User.create(email: 'adam3@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'adam3', last_name: 'Ray', is_admin: false)
    user3.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!
    
    feedback1 = save_feedback(1, 1, 1, 1, 1, 1, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 2, 15), team, 0)
    feedback2 = save_feedback(1, 2, 3, 4, 5, 3, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 2, 16), team, 1)
    feedback3 = save_feedback(1, 1, 1, 1, 1, 1, "This team is disorganized", user3, DateTime.civil_from_format(:local, 2021, 2, 17), team, 2)
    
    team_weighted_priority = team.find_priority_weighted(week_range[:start_date], week_range[:end_date])
    assert_equal "High", team_weighted_priority
  end
  
  def test_find_priority_weighted_team_summary_medium_status
    week_range = week_range(2021, 7)
    
    user1 = User.create(email: 'adam1@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'adam1', last_name: 'Ray', is_admin: false)
    user1.save!
    user2 = User.create(email: 'adam2@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'adam2', last_name: 'Ray', is_admin: false)
    user2.save!
    user3 = User.create(email: 'adam3@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'adam3', last_name: 'Ray', is_admin: false)
    user3.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!
    
    feedback1 = save_feedback(1, 1, 1, 1, 1, 1, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 2, 15), team, 2)
    feedback2 = save_feedback(1, 1, 1, 1, 1, 1, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 2, 16), team, 1)
    feedback3 = save_feedback(1, 1, 1, 1, 1, 1, "This team is disorganized", user3, DateTime.civil_from_format(:local, 2021, 2, 17), team, 2)
    
    team_weighted_priority = team.find_priority_weighted(week_range[:start_date], week_range[:end_date])
    assert_equal "Medium", team_weighted_priority
  end
  
  def test_find_priority_weighted_team_summary_low_status
    week_range = week_range(2021, 7)
    
    user1 = User.create(email: 'adam1@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'adam1', last_name: 'Ray', is_admin: false)
    user1.save!
    user2 = User.create(email: 'adam2@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'adam2', last_name: 'Ray', is_admin: false)
    user2.save!
    user3 = User.create(email: 'adam3@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'adam3', last_name: 'Ray', is_admin: false)
    user3.save!
    course1 = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    course1.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: course1)
    team.save!
    
    feedback1 = save_feedback(1, 1, 1, 1, 1, 1, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 2, 15), team, 2)
    feedback2 = save_feedback(5, 5, 5, 5, 5, 5, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 2, 16), team, 2)
    feedback3 = save_feedback(5, 5, 5, 5, 5, 5, "This team is disorganized", user3, DateTime.civil_from_format(:local, 2021, 2, 17), team, 2)
    
    team_weighted_priority = team.find_priority_weighted(week_range[:start_date], week_range[:end_date])
    assert_equal "Low", team_weighted_priority
  end
  
  def test_multi_feedback_average_rating_team_summary
    week_range = week_range(2021, 7)
    
    user1 = User.create(email: 'adam1@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'adam1', last_name: 'Ray', is_admin: false)
    user1.save!
    user2 = User.create(email: 'adam2@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'adam2', last_name: 'Ray', is_admin: false)
    user2.save!
    user3 = User.create(email: 'adam3@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'adam3', last_name: 'Ray', is_admin: false)
    user3.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!
    
    feedback1 = save_feedback(3, 3, 3, 3, 3, 3, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 2, 15), team, 2)
    feedback2 = save_feedback(3, 3, 3, 3, 3, 3, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 2, 16), team, 2)
    feedback3 = save_feedback(3, 3, 3, 3, 3, 3, "This team is disorganized", user3, DateTime.civil_from_format(:local, 2021, 2, 17), team, 2)
    
    
    current_week_average = Team.feedback_average_rating(team.feedback_by_period.first[1])
    assert_equal 3.0, current_week_average
  end
  
  def test_single_feedback_average_rating_team_summary
    week_range = week_range(2021, 7)
    
    user1 = User.create(email: 'adam1@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'adam1', last_name: 'Ray', is_admin: false)
    user1.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!
    
    feedback1 = save_feedback(5, 5, 5, 5, 5, 5, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 2, 15), team, 2)
    
    current_week_average = Team.feedback_average_rating(team.feedback_by_period.first[1])
    assert_equal 5.0, current_week_average
  end
  
  def test_find_priority_weighted_no_feedbacks 
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!
    
    team_weighted_priority = team.find_priority_weighted(DateTime.civil_from_format(:local, 2021, 2, 15), DateTime.civil_from_format(:local, 2021, 2, 21))
    assert_nil team_weighted_priority
  end
  
   def test_find_students_not_submitted_no_submissions
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Ray', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Ray', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles3', last_name: 'Ray', is_admin: false)

    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!   
    user1.join_team_statuses.create(team: team, status: 1)
    user2.join_team_statuses.create(team: team, status: 1)
    team2 = Team.new(team_code: 'Code2', team_name: 'Team 2', course: @course)
    team2.save 
    user3.join_team_statuses.create(team: team2, status: 1)

    # No submissions made yet 
    assert_equal([user1, user2], team.users_not_submitted([]))
  end 

  def test_find_students_not_submitted_partial_submissions
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Ray', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Ray', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles3', last_name: 'Ray', is_admin: false)

    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!   
    user1.join_team_statuses.create(team: team, status: 1)
    user2.join_team_statuses.create(team: team, status: 1)
    team2 = Team.new(team_code: 'Code2', team_name: 'Team 2', course: @course)
    team2.save 
    user3.join_team_statuses.create(team: team2, status: 1)

    feedback = save_feedback(5, 5, 5, 5, 5, 5, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2)


    # No submissions made yet 
    assert_equal([user2], team.users_not_submitted([feedback]))

    feedback = save_feedback(5, 5, 5, 5, 5, 5, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2)
    feedback2 = save_feedback(5, 4, 3, 1, 2, 3, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2)
    feedback3 = save_feedback(4, 4, 4, 4, 4, 4, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 2, 15), team, 2)
    feedback4 = save_feedback(5, 5, 5, 5, 5, 5, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 2, 16), team, 2)
  end

  def test_find_students_not_submitted_all_submitted
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Ray', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Ray', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles3', last_name: 'Ray', is_admin: false)

    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!   
    user1.join_team_statuses.create(team: team, status: 1)
    user2.join_team_statuses.create(team: team, status: 1)
    team2 = Team.new(team_code: 'Code2', team_name: 'Team 2', course: @course)
    team2.save
    user3.join_team_statuses.create(team: team2, status: 1)

    feedback = save_feedback(5, 5, 5, 5, 5, 5, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2)
    feedback2 = save_feedback(3, 3, 3, 3, 3, 3, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2)
    assert_equal([], team.users_not_submitted([feedback, feedback2]))
  end

  def test_find_students_not_submitted_over_submitted 
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Ray', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Ray', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles3', last_name: 'Ray', is_admin: false)

    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!   
    user1.join_team_statuses.create(team: team, status: 1)
    user2.join_team_statuses.create(team: team, status: 1)
    team2 = Team.new(team_code: 'Code2', team_name: 'Team 2', course: @course)
    team2.save
    user3.join_team_statuses.create(team: team2, status: 1)

    feedback = save_feedback(5, 5, 5, 5, 5, 5, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2)
    feedback2 = save_feedback(3, 3, 3, 3, 3, 3, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2)
    feedback3 = save_feedback(1, 4, 3, 5, 2, 3, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 2), team, 2)
    assert_equal([], team.users_not_submitted([feedback, feedback2, feedback3]))
  end 

  def test_find_students_not_submitted_user_not_in_team
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Ray', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Ray', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles3', last_name: 'Ray', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!    
    user1.join_team_statuses.create(team: team, status: 1)
    user2.join_team_statuses.create(team: team, status: 1)
    team2 = Team.new(team_code: 'Code2', team_name: 'Team 2', course: @course)
    team2.save
    user3.join_team_statuses.create(team: team2, status: 1)

    feedback = save_feedback(5, 5, 5, 5, 5, 5, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2)
    feedback2 = save_feedback(5, 4, 3, 1, 2, 3, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2)
    feedback3 = save_feedback(4, 4, 4, 4, 4, 4, "This team is disorganized", user3, DateTime.civil_from_format(:local, 2021, 3, 2), team2, 2)
    assert_equal([], team.users_not_submitted([feedback, feedback2, feedback3]))
  end

  def test_find_current_feedback 
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Ray', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Ray', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles3', last_name: 'Ray', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!     
    user1.join_team_statuses.create(team: team, status: 1)
    user2.join_team_statuses.create(team: team, status: 1)

    feedback = save_feedback(5, 5, 5, 5, 5, 5, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2)
    feedback2 = save_feedback(5, 1, 3, 4, 2, 3, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2)
    feedback3 = save_feedback(4, 4, 4, 2, 2, 3, "This team is disorganized", user3, DateTime.civil_from_format(:local, 2021, 4, 2), team, 2)
    result = team.current_feedback(d=Date.new(2021, 3, 2))
    assert_includes( result, feedback )
    assert_includes( result, feedback2 )
    refute_includes( result, feedback3 )
    assert_equal( 2, result.length )
  end
  
  def test_generate_team_code 
    assert_equal(6, Team::generate_team_code(length = 6).size)
  end

  def test_order_by 
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    assert Team::order_by(team.team_code)
  end
  
  def test_status_no_users 
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Ray', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Ray', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles3', last_name: 'Ray', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!     

    assert_equal('grey', team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3)))
  end
  
  def test_status_no_feedback 
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Ray', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Ray', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles3', last_name: 'Ray', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!     
    user1.join_team_statuses.create(team: team, status: 1)
    user2.join_team_statuses.create(team: team, status: 1)

    feedback = save_feedback(3, 3, 3, 3, 3, 3, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2)
    feedback2 = save_feedback(3, 3, 3, 3, 3, 3, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2)

    assert_equal('grey', team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3)))
  end
  
  def test_green_status
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Ray', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Ray', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles3', last_name: 'Ray', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!     
    user1.join_team_statuses.create(team: team, status: 1)
    user2.join_team_statuses.create(team: team, status: 1)

    feedback = save_feedback(3, 3, 3, 3, 3, 3, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 0)
    feedback2 = save_feedback(5, 5, 5, 5, 5, 5, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 27), team, 2)
    feedback3 = save_feedback(3, 3, 3, 3, 3, 3, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 4, 2), team, 2)
    
    assert_equal('green', team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3)))
  end
  
  def test_yellow_status_rating
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Ray', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Ray', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles3', last_name: 'Ray', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!     
    user1.join_team_statuses.create(team: team, status: 1)
    user2.join_team_statuses.create(team: team, status: 1)

    feedback = save_feedback(1, 2, 3, 4, 5, 3, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 0)
    feedback2 = save_feedback(3, 3, 3, 3, 3, 3, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 27), team, 2)
    feedback3 = save_feedback(5, 2, 1, 3, 4, 3, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 4, 2), team, 2)
    
    assert_equal('yellow', team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3)))
  end
  
  def test_yellow_status_priority
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Ray', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Ray', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles3', last_name: 'Ray', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!     
    user1.join_team_statuses.create(team: team, status: 1)
    user2.join_team_statuses.create(team: team, status: 1)

    feedback = save_feedback(2, 2, 2, 2, 2, 2, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 0)
    feedback2 = save_feedback(4, 4, 4, 4, 4, 4, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 27), team, 1)
    feedback3 = save_feedback(5, 5, 5, 5, 5, 5, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 4, 2), team, 2)
    
    assert_equal('yellow', team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3)))
  end
  
  def test_red_status_priority
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Ray', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Ray', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles3', last_name: 'Ray', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!     
    user1.join_team_statuses.create(team: team, status: 1)
    user2.join_team_statuses.create(team: team, status: 1)

    feedback = save_feedback(2, 2, 2, 2, 2, 2, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 0)
    feedback2 = save_feedback(1, 1, 1, 1, 1, 1, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 27), team, 0)
    feedback3 = save_feedback(5, 5, 5, 5, 5, 5, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 4, 2), team, 2)
    
    assert_equal('red', team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3)))
  end
  
  def test_red_status_based_on_priority
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Ray', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Ray', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles3', last_name: 'Ray', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!     
    user1.join_team_statuses.create(team: team, status: 1)
    user2.join_team_statuses.create(team: team, status: 1)

    feedback = save_feedback(2, 2, 2, 2, 2, 2, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2)
    feedback2 = save_feedback(2, 2, 2, 2, 2, 2, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 27), team, 2)
    feedback3 = save_feedback(5, 5, 5, 5, 5, 5, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 4, 2), team, 0)
    
    assert_equal('red', team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3)))
  end

  def test_red_status_based_on_rating
    user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Ray', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Ray', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles3', last_name: 'Ray', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
    team.save!     
    user1.join_team_statuses.create(team: team, status: 1)
    user2.join_team_statuses.create(team: team, status: 1)

    feedback = save_feedback(2, 2, 2, 2, 2, 2, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2)
    feedback2 = save_feedback(2, 2, 2, 2, 2, 2, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 27), team, 2)
    feedback3 = save_feedback(1, 1, 1, 1, 1, 1, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 4, 2), team, 2)
    
    assert_equal('red', team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3)))
  end
end
