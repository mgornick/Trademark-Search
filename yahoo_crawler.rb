require 'rubygems'
require 'nokogiri'

class YahooCrawler
  attr_accessor :organic, :page, :sponsored_cites, :ad_positions
  
  def initialize(webpage)
    self.organic = []
    self.ad_positions = []
    self.sponsored_cites = []
    self.page = webpage
  end
  
  def total_organic_results
    Nokogiri::HTML(self.page).css("strong[@id='resultCount']").children.first.to_s.gsub(",","").gsub("\n","").gsub(" ","")
  end

  def organic_results(number)
    self.organic = []
    doc = Nokogiri::HTML(page) # let nokogiri parse the DOM
    
    results = doc.css("div[@id='web']/ol/li/div[@class='res']/div/h3/a")
    results.each do |link|
      self.organic << link[:href]
    end
    
    self.organic = self.organic[0..number-1]
  end
  
  def remove_html(text)
    clean = ""
    ignore = false
    
    text.each_char do |char| # parses out all the code between <>
      if char == "<"
        ignore = true
      elsif char == ">"
        ignore = false
      elsif !ignore
        clean << char
      end
    end
    
    return clean
  end
    
  def sponsored_results(number)
    self.sponsored_cites = []
    self.ad_positions = []
    doc = Nokogiri::HTML(page) # let nokogiri parse the DOM
    
    # top
    # top_results = doc.css("div[@class='ads']/ul[@class='spns reducepx-spnslist']/li/em/b")
    top_results = doc.css("div[@id='main']/div[@class='ads horiz']/ul[@class='spns reducepx-spnslist']/li/em")
    # puts top_results.inspect
    top_results.each do |link|
      cite_link = self.remove_html(link.to_s)
      cite_link = cite_link.gsub(' ', '').gsub("\n", '').gsub("\r", '').gsub("\t",'').downcase
      if cite_link.scan('http').first
        self.sponsored_cites << cite_link
      else
        self.sponsored_cites << "http://" + cite_link
      end
      self.ad_positions << 'Top'
    end
    
    # # Right 
    right_results = doc.css("div[@id='east']/ul/li/em")
    right_results.each do |link|
      cite_link = self.remove_html(link.to_s)
      cite_link = cite_link.gsub(' ', '').gsub("\n", '').gsub("\r", '').gsub("\t",'').downcase
      if cite_link.scan('http').first
        self.sponsored_cites << cite_link
      else
        self.sponsored_cites << "http://" + cite_link
      end
      self.ad_positions << 'Right'
    end
    
    #Bottom
    bottom_results = doc.css("div[@class='ads horiz bot']/ul/li/em")
    bottom_results.each do |link|
      cite_link = self.remove_html(link.to_s)
      cite_link = cite_link.gsub(' ', '').gsub("\n", '').gsub("\r", '').gsub("\t",'').downcase
      if cite_link.scan('http').first
        self.sponsored_cites << cite_link
      else
        self.sponsored_cites << "http://" + cite_link
      end
      self.ad_positions << 'Bottom'
    end
    
    self.sponsored_cites = self.sponsored_cites[0..number-1]
  end
  
end