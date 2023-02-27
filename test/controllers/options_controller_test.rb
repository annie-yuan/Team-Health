require 'test_helper'

class OptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # create test user
    @user = User.new(email: 'charles@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Ray', is_admin: false)
    @user.save
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.new(team_code: 'Code2', team_name: 'Team 1')
  end
  
  def test_enable_reports
    Option.destroy_all
    Option.create(reports_toggled: false)
    post(login_path, params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    post option_toggle_reports_path(Option.first)
    assert_equal(Option.first.reports_toggled, true)
  end
  
  def test_disable_reports
    Option.destroy_all
    Option.create(reports_toggled: true)
    post(login_path, params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    post option_toggle_reports_path(Option.first)
    assert_equal(Option.first.reports_toggled, false)
  end
  
  def test_cannot_toggle_reports_as_non_admin
    Option.destroy_all
    Option.create(reports_toggled: false)
    post(login_path, params: { email: 'charles@uwaterloo.ca', password: 'banana'})
    post option_toggle_reports_path(Option.first)
    assert_equal(Option.first.reports_toggled, false) # Ensure that reports_toggle remains false
  end
  
  def test_regenerate_option_code 
    Option.destroy_all 
    Option.create(reports_toggled: true, admin_code: 'test')
    post(login_path, params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    get regenerate_admin_code_url
    assert_not_equal('test', Option.first.admin_code)
  end 
  
  def test_regenerate_option_code_non_admin 
    Option.destroy_all 
    Option.create(reports_toggled: true, admin_code: 'test')
    post(login_path, params: { email: 'charles@uwaterloo.ca', password: 'banana'})
    get regenerate_admin_code_url
    assert_equal('test', Option.first.admin_code)
  end 
end
