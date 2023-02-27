require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  #driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  driven_by :rack_test
  # need to set this to overcome a bug with rails 6.1.4 ( https://github.com/rails/rails/issues/42780 )
  Capybara.app_host = 'http://127.0.0.1'
  
  Option.delete_all
  option = Option.create(reports_toggled: true)
  option.generate_admin_code(6)
end
