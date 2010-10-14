require 'capybara'
require 'capybara/dsl'
require 'capybara/envjs'


class Trademark < ActiveRecord::Base
  has_many :search_results
  has_many :search_ads
  
  def self.import
    Trademark.delete_all
    SearchResult.delete_all
    SearchAd.delete_all
    
    trademarks = IO.read('trademarks.txt').split("\n")
    trademarks.each do |trademark|
      if Trademark.find(:first, :conditions => {:term => trademark}).nil?
        
        puts "Adding the trademark " + trademark + " to the database."
        Trademark.create(:term => trademark)
      end
    end
    true
  end
  
  def retrieve_google_search_page #testing of culerity
    # puts "\t searching google..."
    # Capybara.visit('http://www.google.com/webhp?complete=0&hl=en')
    # puts "\t visited page..."
    # Capybara.fill_in "q", :with => self.term
    # puts "\t entered search term..."
    # Capybara.click 'Google Search'
    # puts "\t clicked search..."
    # sleep(4)
    puts "\t searching google..."
    Capybara.visit("http://www.google.com/search?q=" + self.term)
    self.google_search_page = Capybara.page.body.to_s
    puts "\t saving html page..."
  end
  
  def retrieve_yahoo_search_page #testing of culerity
    # Capybara.visit('http://search.yahoo.com')
    # puts "\t visited page..."
    # Capybara.fill_in 'Search query', :with => self.term
    # puts "\t entered search term..."
    # Capybara.click 'Search'
    # puts "\t clicked search..."
    # sleep(4)
    
    puts "\t searching yahoo..."    
    Capybara.visit("http://search.yahoo.com/search;_ylt=" + rand(1000000).to_s + "?p=" + self.term)
    self.yahoo_search_page = Capybara.page.body.to_s
    puts "\t saving html page..."
  end
  
  def retrieve_bing_search_page #testing of culerity
    puts "\t searching bing..."
    Capybara.visit("http://www.bing.com/search?q=" + self.term)
    self.bing_search_page = Capybara.page.body.to_s
  end
  
  def self.scrape
    Capybara.run_server = false
    # Capybara.current_driver = :culerity
    Capybara.current_driver = :selenium 
    
    
    Trademark.all.each do |t|
      start_time = Time.now
      puts "Working on " + t.term
      t.perform_searches
      end_time = Time.now
      
      single_trademark_time = end_time - start_time      
      incomplete = Trademark.count(:conditions => {:complete => nil})
      puts "Estimated time remaining to complete search: " + (single_trademark_time * incomplete/3600).to_s + " hours" 
    end
    
    return true
  end
  
  def perform_searches
    return true if self.complete
    
    #delete old search and ad results if crash
    self.search_results.delete_all
    self.search_ads.delete_all
    
    self.retrieve_google_search_page
    self.retrieve_yahoo_search_page
    self.retrieve_bing_search_page
    
    self.complete = true
    self.save
    
    puts "completed " + self.term
  end
  
  def search_internet
    return true if self.complete
    self.search_results.delete_all
    self.search_ads.delete_all  
    
    # bing 
    Capybara.run_server = false
    Capybara.current_driver = :culerity
    Capybara.app_host = 'http://www.bing.com'
    Capybara.visit('/')
    Capybara.fill_in "sb_form_q", :with => self.term
    Capybara.click 'sb_form_go'
    
    self.bing_search_page = Capybara.page.body.to_s
    b = BingCrawler.new(Capybara.page.body.to_s)
    b.organic_results(10)
    b.organic.each do |organic|
      self.search_results.create(:url => organic, :search_engine => "Bing")
    end

    b.sponsored_results(15)
    b.sponsored_cites.each_index do |i|
      sponsored = b.sponsored_cites[i]
      self.search_ads.create(:url => sponsored, :search_engine => "Bing", :location => b.ad_positions[i].to_s)
    end
    
    # google
    Capybara.app_host = 'http://www.google.com'
    Capybara.visit('/')
    Capybara.fill_in "q", :with => self.term
    Capybara.click 'Google Search'
    self.google_search_page = Capybara.page.body.to_s
    b = GoogleCrawler.new(Capybara.page.body.to_s)
    b.organic_results(10)
    b.organic.each do |organic|
      self.search_results.create(:url => organic, :search_engine => "Google")
    end
    b.sponsored_results(15)
    b.sponsored_cites.each_index do |i|
      sponsored = b.sponsored_cites[i]
      self.search_ads.create(:url => sponsored, :search_engine => "Google", :location => b.ad_positions[i].to_s)
    end
    
    #yahoo
    Capybara.app_host = 'http://search.yahoo.com/' # http://search.yahoo.com/ loads faster and it's easier to find the textfield
    Capybara.visit('/')
    Capybara.fill_in 'p', :with => self.term
    Capybara.click 'Search'
    self.yahoo_search_page = Capybara.page.body.to_s
    b = YahooCrawler.new(Capybara.page.body.to_s)
    b.organic_results(10)
    b.organic.each do |organic|
      self.search_results.create(:url => organic, :search_engine => "Yahoo")
    end
    b.sponsored_results(15)
    b.sponsored_cites.each_index do |i|
      sponsored = b.sponsored_cites[i]
      self.search_ads.create(:url => sponsored, :search_engine => "Yahoo", :location => b.ad_positions[i].to_s)
    end
    
    self.complete = true
    self.save
  end
  
  def export_links_to_pdfs
    
  end
  
  def self.export_as_csv
    
  end
  
  
end
