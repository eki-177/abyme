RSpec.configure do |config|
  config.include Capybara::DS

  Capybara.register_driver :headless_chrome do |app|
    options = Selenium::WebDriver::Chrome::Options.new(args: %w[no-sandbox headless disable-gpu window-size=1400,900])
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end
  Capybara.save_path = Rails.root.join('tmp/capybara')
  Capybara.javascript_driver = :headless_chrome
end