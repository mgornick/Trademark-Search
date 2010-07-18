require 'google_crawler'
require 'bing_crawler'
require 'yahoo_crawler'
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
      self.search_bing(trademark)
      # self.search_google(trademark)
      # self.search_yahoo(trademark)
    end
  end

  def load_file
    puts 'Loading trademarks'
    return IO.read('trademarks.txt').split("\n")
  end
  
  def fetch_page(url)
    puts "Grabbing: "+url 
    Net::HTTP.get(URI.parse(url))
  end

  def export_links_to_files(search_term, organic_results, prefix)
    puts "Running "+prefix+": "+search_term
    organic_results.each_index do |index|
      begin
        puts "Converting #{organic_results[index]} to PDF"
        if self.fetch_page(organic_results[index])
          PDFKit.new(organic_results[index]).to_file(search_term+'/'+search_term+prefix+index.to_s+'.pdf')
        end
          
      rescue Exception => e
        puts "Caught an exception trying to generate PDF for " + organic_results[index]
        puts "Error message" + e
        PDFKit.new("Page failed to load:" + organic_results[index]).to_file(search_term+'/'+search_term+prefix+index.to_s+'.pdf')
      end
    end
  end
  
  def export_sponsored_links_to_files(search_term, cites, prefix, adurls)
    puts "Exporting ads "+prefix+": "+search_term
    cites.each_index do |index|
      puts "Converting #{cites[index]} to PDF"
      begin
        if self.fetch_page(cites[index])
          PDFKit.new(cites[index]).to_file(search_term+'/'+search_term+prefix+index.to_s+'.pdf')
        end
      rescue Exception => e0
        puts "Caught an exception trying to generate PDF for " + cites[index]
        puts "Error message" + e0
        begin
          puts "Trying the cite link: " + adurls[index]
          if self.fetch_page(adurls[index])
            PDFKit.new(adurls[index]).to_file(search_term+'/'+search_term+prefix+index.to_s+'.pdf')
          end
        rescue Exception => e1
          puts "Could not generate PDF for: " + adurls[index]
          puts "Error message " + e1
          PDFKit.new("Page failed to load:" + cites[index]).to_file(search_term+'/'+search_term+prefix+index.to_s+'.pdf')
        end
      end
    end
  end
  
  # search google
  def search_google(search_term)
    # turn off rack server since we're running against a remote app
    Capybara.run_server = false    
    Capybara.current_driver = :culerity
    Capybara.app_host = 'http://www.google.com'
    Capybara.visit('/')
    Capybara.fill_in "q", :with => search_term
    Capybara.click 'Google Search'
    
    google_page = Capybara.page.body.to_s
    PDFKit.new(google_page).to_file(search_term+'/'+search_term+'_google.pdf')
    
    g = GoogleCrawler.new(google_page)
    g.organic_results(10)
    g.sponsored_results(10)
        
    self.export_links_to_files(search_term, g.organic, '_google_OL')
    self.export_sponsored_links_to_files(search_term, g.sponsored_cites, '_google_SL', g.sponsored_adurls)    
  end
  
  def search_bing(search_term)
    # turn off rack server since we're running against a remote app  
    Capybara.run_server = false
    Capybara.current_driver = :culerity
    Capybara.app_host = 'http://www.bing.com'
    Capybara.visit('/')
    Capybara.fill_in "sb_form_q", :with => search_term
    Capybara.click 'sb_form_go'
    
    bing_page = Capybara.page.body.to_s
    PDFKit.new(bing_page).to_file(search_term+'/'+search_term+'_bing.pdf')
    
    b = BingCrawler.new(bing_page)
    b.organic_results(10)
    b.sponsored_results(10)
    
        
    #self.export_links_to_files(search_term, b.organic, '_bing_OL')
    self.export_sponsored_links_to_files(search_term, b.sponsored_cites, '_bing_SL', b.sponsored_adurls)    
  end
  
  # search yahoo
  def search_yahoo(search_term) 
    Capybara.run_server = false # turn off rack server since we're running against a remote app
    Capybara.current_driver = :culerity
    Capybara.app_host = 'http://search.yahoo.com/' # http://search.yahoo.com/ loads faster and it's easier to find the textfield
    Capybara.visit('/')
    Capybara.fill_in 'p', :with => search_term
    Capybara.click 'Search'
    
    yahoo_page = Capybara.page.body.to_s
    
    yahoo_pdf = PDFKit.new(yahoo_page)
    yahoo_pdf.stylesheets << "yahoo_styling.css"
    puts yahoo_pdf.stylesheets # add custome styling so yahoo doesn't add the line through all the text
    yahoo_pdf.to_file(search_term+'/'+search_term+'_yahoo.pdf')
  
    y = YahooCrawler.new(yahoo_page)

    y.organic_results(10)
    y.sponsored_results(10)

    self.export_links_to_files(search_term, y.organic, '_yahoo_OL')
    self.export_links_to_files(search_term, y.sponsored_cites, '_yahoo_SL')
  end

end

