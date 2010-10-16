require 'capybara'
require 'capybara/dsl'
require 'capybara/envjs'
require 'fileutils'

SLEEP_TIME = 3 # number of seconds to wait between each search

class Trademark < ActiveRecord::Base
  has_many :search_results
  has_many :search_ads
  
  def self.import # deletes all prior results and loads in trademarks via text file
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
    puts "\t searching google..."
    Capybara.visit("http://www.google.com/search?q=" + self.term)
    sleep(SLEEP_TIME)
    self.google_search_page = Capybara.page.body.to_s
    puts "\t saving html page..."
  end
  
  def retrieve_yahoo_search_page #testing of culerity
    puts "\t searching yahoo..."    
    Capybara.visit("http://search.yahoo.com/search;_ylt=" + rand(1000000).to_s + "?p=" + self.term)
    sleep(SLEEP_TIME)
    self.yahoo_search_page = Capybara.page.body.to_s
    puts "\t saving html page..."
  end
  
  def retrieve_bing_search_page #testing of culerity
    puts "\t searching bing..."
    Capybara.visit("http://www.bing.com/search?q=" + self.term)
    sleep(SLEEP_TIME)
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
  
  def self.links
    Trademark.find(:all, :conditions => {:complete => true}).each do |t|
      puts "Determining Organic and Sponsored links for " + t.term
      t.determine_organic_links
      t.determine_sponsored_links
    end
    true
  end
  
  def self.pdfs
    Trademark.all.each do |t|
      puts "Generating PDF for " + t.term
      t.export_to_pdf
    end
  end
  
  def export_to_pdf
    trademark_name = self.term.downcase.scan(/\w+/).to_s
    filepath = "#{RAILS_ROOT}/TRADEMARKS/" + trademark_name
    
    FileUtils.mkdir_p(filepath)

    google_page = PDFKit.new(self.google_search_page)
    yahoo_page  = PDFKit.new(self.yahoo_search_page)
    bing_page   = PDFKit.new(self.bing_search_page)
    
    google_page.to_file( filepath + "/#{trademark_name}_google.pdf")
    yahoo_page.to_file(  filepath + "/#{trademark_name}_yahoo.pdf")
    bing_page.to_file(   filepath + "/#{trademark_name}_bing.pdf")
    
    puts "Exporting " + trademark_name + " to pdf..."
  end
  
  def export_to_csv(file)
    
  end
  
  def self.excel
    excel_file = File.new("trademark_results_"+Time.now.strftime("%m-%d-%Y_%I:%M%p")+".csv", "w")
    
    Trademark.all.each do |t|
      puts "Exporting to Excel for " + t.term
      t.export_to_csv(excel_file)
    end
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

  
  def determine_organic_links
    begin
      self.search_results.find(:all).map {|i| i.destroy}
      
      google = GoogleCrawler.new(self.google_search_page)
      yahoo = YahooCrawler.new(self.yahoo_search_page)
      bing = BingCrawler.new(self.bing_search_page)

      total_organic_results = 15

      google.organic_results(total_organic_results)
      yahoo.organic_results(total_organic_results)
      bing.organic_results(total_organic_results)


      google.organic.each do |organic|
        self.search_results.create(:url => organic, :search_engine => "Google")
      end
      self.total_google_results = google.total_organic_results

      yahoo.organic.each do |organic|
        self.search_results.create(:url => organic, :search_engine => "Yahoo")
      end
      self.total_yahoo_results = yahoo.total_organic_results
      
      bing.organic.each do |organic|
        self.search_results.create(:url => organic, :search_engine => "Bing")
      end
      self.total_bing_results = bing.total_organic_results
      
      
    rescue Exception => e
      puts "Error trying to determing search links for " + self.term
      puts e.inspect
    end
    
    puts "Found " + self.search_results.count.to_s + " organic search results for " + self.term

    return true
  end
  
  def determine_sponsored_links
    begin
      self.search_ads.find(:all).map {|i| i.destroy}
      
      google = GoogleCrawler.new(self.google_search_page)
      yahoo = YahooCrawler.new(self.yahoo_search_page)
      bing = BingCrawler.new(self.bing_search_page)
      
      total_sponsored_results = 15

      google.sponsored_results(total_sponsored_results)
      yahoo.sponsored_results(total_sponsored_results)
      bing.sponsored_results(total_sponsored_results)
      
      puts google.sponsored_cites


      google.sponsored_cites.each_index do |i|
        sponsored = google.sponsored_cites[i]
        self.search_ads.create(:url => sponsored, :search_engine => "Google", :location => google.ad_positions[i].to_s)
      end
      
      yahoo.sponsored_cites.each_index do |i|
        sponsored = yahoo.sponsored_cites[i]
        self.search_ads.create(:url => sponsored, :search_engine => "Yahoo", :location => yahoo.ad_positions[i].to_s)
      end
      
      bing.sponsored_cites.each_index do |i|
        sponsored = bing.sponsored_cites[i]
        self.search_ads.create(:url => sponsored, :search_engine => "Bing", :location => bing.ad_positions[i].to_s)
      end
      
    rescue Exception => e
      puts "Error trying to determing search links for " + self.term
      puts e.inspect
    end
    
    puts "Found " + self.search_ads.count.to_s + " sponsored search results for " + self.term

    return true
  end
end
