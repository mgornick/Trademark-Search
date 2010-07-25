require 'google_crawler'
require 'bing_crawler'
require 'yahoo_crawler'
require 'capybara'
require 'capybara/dsl'
require 'net/http'
require 'fileutils'

class GlobalCrawler
  attr_accessor :output
  
  def start
    begin
    trademarks = self.load_file
    self.init_excel_header
    
    if !File.directory?('trademarks')
      FileUtils.mkdir('trademarks') #makes folder for that trademark
    end
    
    trademarks.each do |trademark|
      if !File.directory?('trademarks/' + trademark.to_s)
        FileUtils.mkdir('trademarks/' + trademark.to_s) #makes folder for that trademark
      end
      self.output.write(trademark.to_s + " \t ")
      self.search_bing(trademark)
      self.search_google(trademark)
      self.search_yahoo(trademark)
    end
      
    rescue Exception => e
      puts "Encountered an error: " + e
      self.output.close
    end
  end
  
  def init_excel_header
    self.output = File.new("trademark_results.csv", "w")
    header = ['Trademark']
    header << 'Bing Total OL'
    header << 'Bing Total SL'
    header << 'Bing_OL0'
    header << 'Bing_OL1'
    header << 'Bing_OL2'
    header << 'Bing_OL3'
    header << 'Bing_OL4'
    header << 'Bing_OL5'
    header << 'Bing_OL6'
    header << 'Bing_OL7'
    header << 'Bing_OL8'
    header << 'Bing_OL9'
    
    header << 'Bing_SL0 Position'    
    header << 'Bing_SL0'
    header << 'Bing_SL1 Position' 
    header << 'Bing_SL1'
    header << 'Bing_SL2 Position' 
    header << 'Bing_SL2'
    header << 'Bing_SL3 Position' 
    header << 'Bing_SL3'
    header << 'Bing_SL4 Position' 
    header << 'Bing_SL4'
    header << 'Bing_SL5 Position' 
    header << 'Bing_SL5'
    header << 'Bing_SL6 Position' 
    header << 'Bing_SL6'
    header << 'Bing_SL7 Position' 
    header << 'Bing_SL7'
    header << 'Bing_SL8 Position' 
    header << 'Bing_SL8'
    header << 'Bing_SL9 Position' 
    header << 'Bing_SL9'
    header << 'Bing_SL10 Position' 
    header << 'Bing_SL10'
    header << 'Bing_SL11 Position' 
    header << 'Bing_SL11'
    header << 'Bing_SL12 Position' 
    header << 'Bing_SL12'
    header << 'Bing_SL13 Position' 
    header << 'Bing_SL13'
    header << 'Bing_SL14 Position' 
    header << 'Bing_SL14'
    
    header << 'Google Total OL'
    header << 'Google Total SL'
    header << 'Google_OL0'
    header << 'Google_OL1'
    header << 'Google_OL2'
    header << 'Google_OL3'
    header << 'Google_OL4'
    header << 'Google_OL5'
    header << 'Google_OL6'
    header << 'Google_OL7'
    header << 'Google_OL8'
    header << 'Google_OL9'

    header << 'Google_SL0 Position'               
    header << 'Google_SL0'
    header << 'Google_SL1 Position'
    header << 'Google_SL1'
    header << 'Google_SL2 Position'
    header << 'Google_SL2'
    header << 'Google_SL3 Position'
    header << 'Google_SL3'
    header << 'Google_SL4 Position'
    header << 'Google_SL4'
    header << 'Google_SL5 Position'
    header << 'Google_SL5'
    header << 'Google_SL6 Position'
    header << 'Google_SL6'
    header << 'Google_SL7 Position'
    header << 'Google_SL7'
    header << 'Google_SL8 Position'
    header << 'Google_SL8'
    header << 'Google_SL9 Position'
    header << 'Google_SL9'
    header << 'Google_SL10 Position'
    header << 'Google_SL10'
    header << 'Google_SL11 Position'
    header << 'Google_SL11'
    header << 'Google_SL12 Position'
    header << 'Google_SL12'
    header << 'Google_SL13 Position'
    header << 'Google_SL13'
    header << 'Google_SL14 Position'
    header << 'Google_SL14'
    
    header << 'Yahoo Total OL'
    header << 'Yahoo Total SL'
    header << 'Yahoo_OL0'
    header << 'Yahoo_OL1'
    header << 'Yahoo_OL2'
    header << 'Yahoo_OL3'
    header << 'Yahoo_OL4'
    header << 'Yahoo_OL5'
    header << 'Yahoo_OL6'
    header << 'Yahoo_OL7'
    header << 'Yahoo_OL8'
    header << 'Yahoo_OL9'
    
    header << 'Yahoo_SL0 Position'
    header << 'Yahoo_SL0'
    header << 'Yahoo_SL1 Position'
    header << 'Yahoo_SL1'
    header << 'Yahoo_SL2 Position'
    header << 'Yahoo_SL2'
    header << 'Yahoo_SL3 Position'
    header << 'Yahoo_SL3'
    header << 'Yahoo_SL4 Position'
    header << 'Yahoo_SL4'
    header << 'Yahoo_SL5 Position'
    header << 'Yahoo_SL5'
    header << 'Yahoo_SL6 Position'
    header << 'Yahoo_SL6'
    header << 'Yahoo_SL7 Position'
    header << 'Yahoo_SL7'
    header << 'Yahoo_SL8 Position'
    header << 'Yahoo_SL8'
    header << 'Yahoo_SL9 Position'
    header << 'Yahoo_SL9'
    header << 'Yahoo_SL10 Position'
    header << 'Yahoo_SL10'
    header << 'Yahoo_SL11 Position'
    header << 'Yahoo_SL11'
    header << 'Yahoo_SL12 Position'
    header << 'Yahoo_SL12'
    header << 'Yahoo_SL13 Position'
    header << 'Yahoo_SL13'
    header << 'Yahoo_SL14 Position'
    header << 'Yahoo_SL14'

    
    head = header.map {|i| i.to_s + " \t "}.to_s
    
    self.output.write("#{head}\n")
  end

  def load_file
    puts 'Loading trademarks'
    return IO.read('trademarks.txt').split("\n")
  end
  
  def fetch_page(url)
    puts "Grabbing: "+url.to_s
    Net::HTTP.get(URI.parse(url))
  end

  def export_links_to_files(search_term, organic_results, prefix)
    puts "Running "+prefix.to_s+": "+search_term.to_s
    organic_results.each_index do |index|
      begin
        puts "Converting #{organic_results[index]} to PDF"
        if self.fetch_page(organic_results[index])
          PDFKit.new(organic_results[index]).to_file('trademarks/'+search_term.to_s+'/'+search_term.to_s+prefix.to_s+index.to_s+'.pdf')
        end
          
      rescue Exception => e
        puts "Caught an exception trying to generate PDF for " + organic_results[index].to_s
        puts "Error message" + e.to_s
        PDFKit.new("Page failed to load:" + organic_results[index].to_s).to_file('trademarks/'+search_term.to_s+'/'+search_term.to_s+prefix.to_s+index.to_s+'.pdf')
      end
    end
  end
  
  def export_sponsored_links_to_files(search_term, cites, prefix, adurls)
    puts "Exporting ads "+prefix.to_s+": "+search_term.to_s
    cites.each_index do |index|
      puts "Converting #{cites[index]} to PDF"
      begin
        if self.fetch_page(cites[index])
          PDFKit.new(cites[index]).to_file('trademarks/'+search_term.to_s+'/'+search_term.to_s+prefix.to_s+index.to_s+'.pdf')
        end
      rescue Exception => e0
        puts "Caught an exception trying to generate PDF for " + cites[index].to_s
        puts "Error message" + e0.to_s
        begin
          puts "Trying the cite link: " + adurls[index].to_s
          if self.fetch_page(adurls[index])
            PDFKit.new(adurls[index]).to_file('trademarks/'+search_term.to_s+'/'+search_term.to_s+prefix.to_s+index.to_s+'.pdf')
          end
        rescue Exception => e1
          puts "Could not generate PDF for: " + adurls[index].to_s
          puts "Error message " + e1.to_s
          PDFKit.new("Page failed to load:" + cites[index]).to_file('trademarks/'+search_term.to_s+'/'+search_term.to_s+prefix.to_s+index.to_s+'.pdf')
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
    Capybara.fill_in "q", :with => search_term.to_s
    Capybara.click 'Google Search'
    
    google_page = Capybara.page.body.to_s
    PDFKit.new(google_page).to_file('trademarks/'+search_term.to_s+'/'+search_term.to_s+'_google.pdf')
    
    g = GoogleCrawler.new(google_page)
    g.organic_results(10)
    g.sponsored_results(15)
    
    self.write_seach_results(g)
        
    self.export_links_to_files(search_term, g.organic, '_google_OL')
    self.export_sponsored_links_to_files(search_term, g.sponsored_cites, '_google_SL', g.sponsored_adurls)    
  end
  
  def write_seach_results(search_engine)
    self.output.write(search_engine.total_organic_results.to_s + " \t")
    self.output.write(search_engine.sponsored_cites.size.to_s + " \t ")
    
    self.output.write(search_engine.organic.map {|i| i.to_s+" \t "}.to_s)
    (10-search_engine.organic.size).times {self.output.write(" \t ")} # add additional columns when not 10 links
    
    sponsored_string = ""
    search_engine.sponsored_cites.each_index do |i|
      sponsored_string << search_engine.ad_positions[i].to_s + " \t " + search_engine.sponsored_cites[i].to_s + " \t "
    end
    self.output.write(sponsored_string)
    
    # self.output.write(sponsored_cites.map {|i| i+" \t "}.to_s)
    (15-search_engine.sponsored_cites.size).times {self.output.write(" \t \t")}# add additional columns when not 10 links
  end
  
  def search_bing(search_term)
    # turn off rack server since we're running against a remote app  
    Capybara.run_server = false
    Capybara.current_driver = :culerity
    Capybara.app_host = 'http://www.bing.com'
    Capybara.visit('/')
    Capybara.fill_in "sb_form_q", :with => search_term.to_s
    Capybara.click 'sb_form_go'
    
    bing_page = Capybara.page.body.to_s
    b = BingCrawler.new(bing_page)
    index = bing_page.rindex('.sa_cpt{position:absolute}')
    bing_page = b.convert_absolute_to_static(bing_page, index)
    PDFKit.new(bing_page).to_file('trademarks/'+search_term.to_s+'/'+search_term.to_s+'_bing.pdf')
    
    b = BingCrawler.new(bing_page)
    b.organic_results(10)
    b.sponsored_results(15)
    
    self.write_seach_results(b)
    
    self.export_links_to_files(search_term, b.organic, '_bing_OL')
    self.export_links_to_files(search_term, b.sponsored_cites, '_bing_SL')    
  end
  
  # search yahoo
  def search_yahoo(search_term) 
    Capybara.run_server = false # turn off rack server since we're running against a remote app
    Capybara.current_driver = :culerity
    Capybara.app_host = 'http://search.yahoo.com/' # http://search.yahoo.com/ loads faster and it's easier to find the textfield
    Capybara.visit('/')
    Capybara.fill_in 'p', :with => search_term.to_s
    Capybara.click 'Search'
    
    yahoo_page = Capybara.page.body.to_s
    
    puts "---- \n \n"
    puts yahoo_page
    puts "---- \n \n"
    
    yahoo_pdf = PDFKit.new(yahoo_page)
    yahoo_pdf.stylesheets << "yahoo_styling.css"
    puts yahoo_pdf.stylesheets # add custome styling so yahoo doesn't add the line through all the text
    yahoo_pdf.to_file('trademarks/'+search_term.to_s+'/'+search_term.to_s+'_yahoo.pdf')
  
    y = YahooCrawler.new(yahoo_page)

    y.organic_results(10)
    y.sponsored_results(15)
    
    self.write_seach_results(y)
    self.output.write("\n")

    self.export_links_to_files(search_term, y.organic, '_yahoo_OL')
    self.export_links_to_files(search_term, y.sponsored_cites, '_yahoo_SL')
  end

end

