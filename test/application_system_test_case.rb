require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Incognito, with the password manager off. Without this, submitting the
  # sign-in form makes headless Chrome show its save-password UI, which takes
  # the tab's input focus and never gives it back: every click after login is
  # silently dropped, though JavaScript keeps running and pages keep rendering.
  # Cost a day to find. The app is fine; only the test browser was affected.
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1440, 1000 ] do |options|
    options.add_argument("--incognito")
    options.add_preference("credentials_enable_service", false)
    options.add_preference("profile.password_manager_enabled", false)
  end
end
