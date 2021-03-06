require 'capybara'
require 'capybara/dsl'
require 'fileutils'
require 'csv'

SLEEP_TIME = 4              # number of seconds to wait between each search
TOTAL_SPONSORED_LINKS = 15
TOTAL_ORGANIC_LINKS = 10
LIMIT_PDF_ORGANIC_LINKS = 5
LIMIT_PDF_SPONSORED_LINKS = 5

# Run Trademark.import, Trademark.scrape, Trademark.links, Trademark.pdfs

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
        puts "Adding #{trademark}"
        Trademark.create(:term => trademark)
      end
    end
    true
  end

  def retrieve_google_search_page
    puts "\t searching google"
    Capybara.visit("https://www.google.com")
    Capybara.fill_in "q", :with => self.term
    sleep(SLEEP_TIME)
    search_page = Capybara.save_page(Capybara.page.body)
    file = File.open(search_page, "rb")
    contents = file.read
    File.delete(search_page)

    self.google_search_page = contents
  end

  def retrieve_yahoo_search_page
    puts "\t searching yahoo"
    Capybara.visit("http://www.yahoo.com")
    sleep(SLEEP_TIME)
    Capybara.fill_in "p", :with => self.term
    begin
      Capybara.click_button("Search")
    rescue
    end
    sleep(SLEEP_TIME)
    search_page = Capybara.save_page(Capybara.page.body)
    file = File.open(search_page, "rb")
    contents = file.read
    File.delete(search_page)

    self.yahoo_search_page = contents
  end

  def retrieve_bing_search_page
    puts "\t searching bing"
    Capybara.visit("http://www.bing.com")
    sleep(SLEEP_TIME)
    Capybara.fill_in "q", :with => self.term
    sleep(SLEEP_TIME)
    Capybara.click_button "sb_form_go"
    sleep(SLEEP_TIME)
    search_page = Capybara.save_page(Capybara.page.body)
    file = File.open(search_page, "rb")
    contents = file.read
    File.delete(search_page)

    self.bing_search_page = contents
  end

  def self.scrape
    Capybara.run_server = false
    Capybara.current_driver = :selenium

    Capybara.visit("http://www.illinois.edu")
    home_page = Capybara.save_page

    File.delete(home_page)

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
    "Parsing organic and sponsored links"
    Trademark.find(:all, :conditions => {:complete => true}).each do |t|
      puts ""
      puts t.term
      t.determine_organic_links
      t.determine_sponsored_links
    end
    true
  end

  def self.pdfs
    Trademark.find(:all, :conditions => {:complete => true}).each do |t|
      trademark_name = t.to_slug
      filepath = "#{RAILS_ROOT}/TRADEMARKS/#{trademark_name}"

      if FileTest.directory?(filepath)
        puts "Skipping #{trademark_name} since folders already exist."
      else
        puts "Generating PDF for " + t.term
        t.export_to_pdf
      end
    end
    true
  end

  def export_to_pdf
    #puts "Exporting a maximum of " + LIMIT_PDF_ORGANIC_LINKS.to_s + " organic links."
    puts "Only exporting search pages for each trademark"
    trademark_name = self.to_slug
    filepath = "#{RAILS_ROOT}/TRADEMARKS/" + trademark_name

    FileUtils.mkdir_p(filepath)

    google_page = PDFKit.new(self.google_search_page)
    yahoo_page  = PDFKit.new(self.yahoo_search_page)
    bing_page   = PDFKit.new(self.bing_search_page)

    puts "Exporting " + trademark_name + " to pdf..."
    puts "\t Exporting Google Search Page"
    google_page.to_file( filepath + "/#{trademark_name}_google.pdf")
    #puts "\t Exporting Organic Search Results for Google"
    #self.search_results.find(:all, :limit => LIMIT_PDF_ORGANIC_LINKS, :conditions => {:search_engine => "Google"}).each_with_index do |search_result, index| 
    #  page = PDFKit.new(search_result.url).to_file(  filepath + "/#{trademark_name}_google_OL#{index}.pdf")
    #end

    #puts "\t Exporting Sponsored Links for Google"
    #self.search_ads.find(:all, :limit => LIMIT_PDF_SPONSORED_LINKS, :conditions => {:search_engine => "Google"}).each_with_index do |ad, index|
      #page = PDFKit.new(ad.url).to_file(filepath + "/#{trademark_name}_google_SL#{index}.pdf")
    #end
    
    puts "\t Exporting Yahoo Search Page"
    yahoo_page.to_file(  filepath + "/#{trademark_name}_yahoo.pdf")
    #puts "\t Exporting Organic Search Results for Yahoo"
    #self.search_results.find(:all, :limit => LIMIT_PDF_ORGANIC_LINKS,:conditions => {:search_engine => "Yahoo"}).each_with_index do |search_result, index| 
      #page = PDFKit.new(search_result.url).to_file(  filepath + "/#{trademark_name}_yahoo_OL#{index}.pdf")
    #end
    
    #puts "\t Exporting Sponsored Links for Yahoo"
    #self.search_ads.find(:all, :limit => LIMIT_PDF_SPONSORED_LINKS, :conditions => {:search_engine => "Yahoo"}).each_with_index do |ad, index|
      #page = PDFKit.new(ad.url).to_file(filepath + "/#{trademark_name}_yahoo_SL#{index}.pdf")
    #end
    
    puts "\t Exporting Bing Search Page"
    bing_page.to_file(   filepath + "/#{trademark_name}_bing.pdf")
    #puts "\t Exporting Organic Search Results for Bing"
    #self.search_results.find(:all, :limit => LIMIT_PDF_ORGANIC_LINKS, :conditions => {:search_engine => "Bing"}).each_with_index do |search_result, index| 
      #page = PDFKit.new(search_result.url).to_file(  filepath + "/#{trademark_name}_bing_OL#{index}.pdf")
    #end
    
    #puts "\t Exporting Sponsored Links for Bing"
    #self.search_ads.find(:all, :limit => LIMIT_PDF_SPONSORED_LINKS, :conditions => {:search_engine => "Bing"}).each_with_index do |ad, index|
    #  page = PDFKit.new(ad.url).to_file(filepath + "/#{trademark_name}_bing_SL#{index}.pdf")
    #end
    
    true
  end
  
  
  def self.excel
    csv_string = FasterCSV.generate do |csv|
      #header row
      csv << Trademark.csv_header
      Trademark.find(:all, :conditions => {:complete => true}).each do |t|
        csv << t.csv_row
      end
    end

    File.open("trademark-excel-export-#{Time.now.strftime("%m-%d-%Y-%I_%M%p")}.csv", "w") do |f|
      f.puts csv_string
    end
  end
  
  def perform_searches
    return true if self.complete

    #delete old search and ad results if crash
    self.search_results.delete_all
    self.search_ads.delete_all

    Capybara.reset!
    self.retrieve_google_search_page
    Capybara.reset!
    self.retrieve_yahoo_search_page
    Capybara.reset!
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

      total_organic_results = TOTAL_ORGANIC_LINKS

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

      self.save
    rescue Exception => e
      puts "Error trying to determing search links for " + self.term
      puts e.inspect
    end
    
    puts "#{self.search_results.count} organic"

    return true
  end
  
  def determine_sponsored_links
    begin
      self.search_ads.find(:all).map {|i| i.destroy}

      google = GoogleCrawler.new(self.google_search_page)
      yahoo = YahooCrawler.new(self.yahoo_search_page)
      bing = BingCrawler.new(self.bing_search_page)

      total_sponsored_results = TOTAL_SPONSORED_LINKS

      google.sponsored_results(total_sponsored_results)
      yahoo.sponsored_results(total_sponsored_results)
      bing.sponsored_results(total_sponsored_results)

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

    puts "#{self.search_ads.count} sponsored"
    return true
  end
  #
  # exporting to CSV
  def self.csv_header
    row = ["Trademark"]

    ["Bing", "Google", "Yahoo"].each do |engine|
      row << engine + " Total OL"
      row << engine + " Total SL"
      
      TOTAL_ORGANIC_LINKS.times do |i|
        row << engine + "_OL#{i}"
      end
      
      TOTAL_SPONSORED_LINKS.times do |s|
        row << engine + "_SL#{s} Position"
        row << engine + "_SL#{s}"
      end
    end
    row
  end
  
  def csv_row
    row = [self.term.to_s]
    
    ["Bing", "Google", "Yahoo"].each do |engine|
      row << self.send("total_#{engine.downcase}_results").to_s
      row << self.search_ads.count(:limit => TOTAL_SPONSORED_LINKS, :conditions => {:search_engine => engine}).to_s
      
      organic_results = self.search_results.find(:all, :limit =>TOTAL_ORGANIC_LINKS, :conditions => {:search_engine => engine})
      organic_results.each do |o|
        row << o.url.to_s
      end
      
      if organic_results.size < TOTAL_ORGANIC_LINKS # need to pad the CSV rows if not exactly the max # of organic results
        (TOTAL_ORGANIC_LINKS - organic_results.size).times {row << ""}
      end
      
      ad_results = self.search_ads.find(:all, :limit =>TOTAL_SPONSORED_LINKS, :conditions => {:search_engine => engine})
      ad_results.each do |s|
        row << s.location
        row << s.url
      end
      
      if ad_results.size < TOTAL_SPONSORED_LINKS # need to pad the CSV rows if not exactly the max # of sponsored results
        ((TOTAL_SPONSORED_LINKS - ad_results.size)*2).times {row << ""} # needs to happen twice because of location + url of ads
      end
      
    end
    row
    
    
  end


def to_slug
    #strip the string
    ret = self.term.strip

    #blow away apostrophes
    ret.gsub! /['`]/,""

    # @ --> at, and & --> and
    ret.gsub! /\s*@\s*/, " at "
    ret.gsub! /\s*&\s*/, " and "

    #replace all non alphanumeric, underscore or periods with underscore
     ret.gsub! /\s*[^A-Za-z0-9\.\-]\s*/, '_'  

     #convert double underscores to single
     ret.gsub! /_+/,"_"

     #strip off leading/trailing underscore
     ret.gsub! /\A[_\.]+|[_\.]+\z/,""

     ret
  end
end
