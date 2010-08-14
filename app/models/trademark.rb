require 'capybara'
require 'capybara/dsl'

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
  
  def self.gather_all_links
    Trademark.all.each do |t|
      puts "Working on " + t.term
      t.search_internet
    end
    nil
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
