require 'google_crawler'

class GlobalCrawler
  
  def google(page)
    GoogleCrawler.new(page)
  end
end