require 'google_crawler'
require 'capybara'
require 'capybara/dsl'

class GlobalCrawler
  
  def load_file(filename)
    return IO.read('trademarks.txt').split("\n")
  end
  
  def search_google(term)    
    Capybara.current_driver = :culerity
    Capybara.app_host = 'http://www.google.com'
    Capybara.visit('/')
    Capybara.fill_in "q", :with => 'Honda'
    Capybara.click 'Google Search'
    GoogleCrawler.new(Capybara.page.body.to_s)
  end

end

