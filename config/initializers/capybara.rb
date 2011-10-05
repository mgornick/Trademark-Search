class Capybara::Selenium::Driver
  def find(selector)
    browser.find_elements(:xpath, selector).map { |node| Capybara::Selenium::Node.new(self, node) }
  rescue Selenium::WebDriver::Error::InvalidSelectorError => e
    puts "retrying... InvalidSelectorError"
    sleep 1
    retry
  rescue Selenium::WebDriver::Error::UnhandledError => e
    puts "retrying... UnhandledError"
    sleep 1
    retry
  rescue Selenium::WebDriver::Error::WebDriverError => e
    puts "retrying... WebDriverError"
    sleep 1
    retry
  end
end

