require "application_system_test_case"

class TimeZoneTests
  setup do
    # create prof, team, and user
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
    @team2 = Team.create(team_name: 'Test Team 2', team_code: 'TEAM02', user: @prof)
    
    @bob = User.create(email: 'bob@uwaterloo.ca', first_name: 'Bob', last_name: 'Smith', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.teams << @team
    
    @andy = User.create(email: 'andy@uwaterloo.ca', first_name: 'Andy', last_name: 'Lee', is_admin: false, password: 'testpassword2', password_confirmation: 'testpassword2')
    @andy.teams << @team
    
    @sarah = User.create(email: 'sarah@uwaterloo.ca', first_name: 'Sarah', last_name: 'Pham', is_admin: false, password: 'testpassword3', password_confirmation: 'testpassword3')
    @sarah.teams << @team
    
    @mike = User.create(email: 'mike@uwaterloo.ca', first_name: 'Mark', last_name: 'Hill', is_admin: false, password: 'testpassword4', password_confirmation: 'testpassword4')
    @mike.teams << @team2
  end

  # Test feedback can be viewed, aggregated by team on sunday
  def test_team_aggregated_view_on_sunday
    Time.zone = 'Pacific Time (US & Canada)'

    datetime =  Time.zone.parse("2021-3-21 23:30:00")
    feedback_time = Time.zone.parse("2021-3-20 23:30:00")
    travel_to datetime
    
    #Create Bob's feedback
    feedbackBob = Feedback.new(rating: 5, comments: "This team is OK")
    feedbackBob.timestamp = feedbackBob.format_time(feedback_time)
    feedbackBob.user = @bob
    feedbackBob.team = @bob.teams.first
    feedbackBob.save
    
    feedbackAndy = Feedback.new(rating: 10, comments: "This team is lovely")
    feedbackAndy.timestamp = feedbackAndy.format_time(feedback_time)
    feedbackAndy.user = @andy
    feedbackAndy.team = @andy.teams.first
    feedbackAndy.save
    
    feedbackSarah = Feedback.new(rating: 3, comments: "This team is horrible")
    feedbackSarah.timestamp = feedbackSarah.format_time(feedback_time)
    feedbackSarah.user = @sarah
    feedbackSarah.team = @sarah.teams.first
    feedbackSarah.save
    
    
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    
    #check to see landing page summary view of team's average ratings
    assert_text "Test Team"
    assert_text "TEAM01"
    assert_text "Bob, Andy, Sarah"
    assert_text "6"
    
    #checks all aggregated feedback of a team
    click_on "View Team Aggregated Feedback"
    assert_current_path team_url(@team)
    
    assert_text "Team Name: Test Team"
    assert_text "Team Code: TEAM01"
    assert_text "Team Members: Bob, Andy, Sarah"
    
    #Bob's feedback

    assert_text "Bob"
    assert_text "5"
    assert_text "This team is OK"
    assert_text feedback_time.strftime("%Y-%m-%d %H:%M")
    
    #Andy's Feedback 

    assert_text "Andy"
    assert_text "10"
    assert_text "This team is lovely"
    
    #Sarah's Feedback

    assert_text "Sarah"
    assert_text "3"
    assert_text "This team is horrible"
  end
end
