require 'google_crawler'
require 'capybara'
require 'capybara/dsl'

class GlobalCrawler
  
  def search(term)    
    Capybara.current_driver = :culerity
    Capybara.app_host = 'http://www.google.com'
    Capybara.visit('/')
    Capybara.fill_in "q", :with => 'Honda'
    Capybara.click 'Google Search'
    # puts Capybara.page.body
    self.google(Capybara.page.body.to_s)
  end
  
  def google(page)
    GoogleCrawler.new(page)
  end
end

