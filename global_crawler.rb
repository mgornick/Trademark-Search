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
      # self.search_bing(trademark)
      # self.search_google(trademark)
      self.search_yahoo(trademark)
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
  
  
  def export_links_to_files(search_term, array, prefix, params = {:backup => []})
    puts "Running "+prefix+": "+search_term
    array.each_index do |index|
      puts "Converting #{array[index]} to PDF"
      
      begin
        PDFKit.new(array[index]).to_file(search_term+'/'+search_term+"_"+prefix+index.to_s+'.pdf')
      rescue Exception => e
        puts "Caught an exception trying to generate PDF for " + array[index]
        puts "Error message" + e
        begin
          puts "Trying the cite link: " + params[:backup][index]
          PDFKit.new(params[:backup][index]).to_file(search_term+'/'+search_term+"_"+prefix+index.to_s+'.pdf')
        rescue Exception => ex
          puts "Could not generate PDF for: " + params[:backup][index]
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
    organic = g.organic_results(10)
    sponsored = g.sponsored_results(10)
        
    self.export_links_to_files(search_term, organic, '_google_OL')
    self.export_links_to_files(search_term, sponsored, '_google_SL', {:backup => g.sponsored_cite})    
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
    
    b = BingCrawler.new(bing_page)
    
    #write page to file
    PDFKit.new(bing_page).to_file(search_term+'/'+search_term+'_bing.pdf')
    
    organic = b.organic_results(10)
    sponsored = b.sponsored_results(10)
    
        
    self.export_links_to_files(search_term, organic, '_bing_OL')
    self.export_links_to_files(search_term, sponsored, '_bing_SL')    
  end
  
  # search yahoo
  def search_yahoo(search_term) 
    # turn off rack server since we're running against a remote app
    Capybara.run_server = false 
    Capybara.current_driver = :culerity
    # http://search.yahoo.com/ loads faster and it's easier to find the textfield
    Capybara.app_host = 'http://search.yahoo.com/'
    Capybara.visit('/')
    Capybara.fill_in 'p', :with => search_term
    Capybara.click 'Search'
    
    yahoo_page = Capybara.page.body.to_s
    
    yahoo_pdf = PDFKit.new(yahoo_page)
    yahoo_pdf.stylesheets << "yahoo_styling.css"
    puts yahoo_pdf.stylesheets
    yahoo_pdf.to_file(search_term+'/'+search_term+'_yahoo.pdf')
  
    y = YahooCrawler.new(yahoo_page)

    organic = y.organic_results(10)
    sponsored = y.sponsored_results(10)

    self.export_links_to_files(search_term, organic, '_yahoo_OL')
    self.export_links_to_files(search_term, sponsored, '_yahoo_SL')    
  end

end

