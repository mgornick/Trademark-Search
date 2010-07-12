require 'google_crawler'
require 'bing_crawler'
require 'capybara'
require 'capybara/dsl'
require 'net/http'
require 'fileutils'

class GlobalCrawler
  
  def start
    trademarks = self.load_file
    
    trademarks.each do |trademark|
      if !File.directory?(trademark)
        FileUtils.mkdir(trademark) #makes folder for that trademark
      end
      #self.search_bing(trademark)
      self.search_google(trademark)
    end
    
  end
  
  def load_file
    return IO.read('trademarks.txt').split("\n")
  end
  
  def fetch_page(url)
    puts "Grabbing: "+url 
    Net::HTTP.get(URI.parse(url))
  end
  
  def export_links_to_files(search_term, array, prefix)
    puts "Running "+prefix+": "+search_term
    array.each_index do |index|
      f = File.open(search_term+'/'+search_term+"_"+prefix+index.to_s+'.html', 'w')
      
      if array[index].scan('http://').first
        f.write(self.fetch_page(array[index]))
      else  
        f.write(self.fetch_page('http://'+array[index]))
      end
    end
  end
  
  # search google
  def search_google(search_term)    
    Capybara.current_driver = :culerity
    Capybara.app_host = 'http://www.google.com'
    Capybara.visit('/')
    Capybara.fill_in "q", :with => search_term
    Capybara.click 'Google Search'
    
    google_page = Capybara.page.body.to_s
    
    g = GoogleCrawler.new(google_page)
    
    #write page to file
    f = File.open(search_term+'/'+search_term+'_google.html', 'w')
    f.write(google_page)
    
    organic = g.organic_results(10)
    sponsored = g.sponsored_results(10)
        
    self.export_links_to_files(search_term, organic, 'OL')
    self.export_links_to_files(search_term, sponsored, 'SL')    
  end
  
  def search_bing(search_term)    
    Capybara.current_driver = :culerity
    Capybara.app_host = 'http://www.bing.com'
    Capybara.visit('/')
    Capybara.fill_in "q", :with => search_term
    Capybara.click 'Search'
    
    bing_page = Capybara.page.body.to_s
    
    b = BingCrawler.new(bing_page)
    
    #write page to file
    f = File.open(search_term+'/'+search_term+'_bing.html', 'w')
    f.write(bing_page)
    
    organic = b.organic_results(10)
    sponsored = b.sponsored_results(10)
        
    self.export_links_to_files(search_term, organic, 'OL')
    self.export_links_to_files(search_term, sponsored, 'SL')    
  end

end

