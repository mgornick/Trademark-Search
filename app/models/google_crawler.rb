require 'rubygems'
require 'nokogiri'
require 'pdfkit'

class GoogleCrawler
  attr_accessor :organic, :page, :sponsored_cites, :sponsored_adurls, :ad_positions
  
  def initialize(webpage)
    self.organic = []
    self.ad_positions = []
    self.sponsored_adurls = []
    self.sponsored_cites = []
    self.page = webpage
  end
  
  def total_organic_results
    self.page.scan(/About [0-9|,]+/).first.split.last.gsub(",","").gsub("\n","")
  end

  def organic_results(number)
    self.organic = []
    doc = Nokogiri::HTML(page) # let nokogiri parse the DOM
    
    # results = doc.css("div[@id='ires']/ol/li[@class='g']/h3[@class='r']/a[@class='l']")
    results = doc.css("div[@id='ires']/ol/li/h3[@class='r']/a[@class='l']")
    results.each do |link|
      self.organic << link[:href]
    end
    
    self.organic = self.organic[0..number-1]
  end
  
  def adurl(link) #regex to try an extract the resulting adurl from the sponsored link
    link.scan(/[\w|\d|\-|.]*\.[\w]{3,4}[\/|\w|\d|\-]*[.|\w]*/).last
  end
  
  def sponsored_results(number)
    self.sponsored_adurls = []
    self.sponsored_cites = []
    self.ad_positions = []
    
    doc = Nokogiri::HTML(page) # let nokogiri parse the DOM
    
    # grabbing the cite tag
    # top
    
    top_results = doc.css("div[@id='tads']/ol[@onmouseover='return true']/li[@class='tas']")
    top_results.each do |link|
      cite_link = link.css('cite').text.gsub(' ', '').gsub("\n", '')
      if cite_link.scan('http').first
        self.sponsored_cites << cite_link
      else
        self.sponsored_cites << "http://" + cite_link
      end
      self.ad_positions << 'Top'
    end
    self.sponsored_cites[0..number-1]
    
    results = doc.css("div[@id='tads']/ol[@onmouseover='return true']/li/h3/a")
    results.each do |link|
      cite_link = self.adurl(link[:href])
      if cite_link.scan('http://').first
        self.sponsored_adurls << cite_link
      else
        self.sponsored_adurls << "http://" + cite_link
      end
    end
    
    self.sponsored_adurls[0..number-1]
    
    
    # Right
    results = doc.css("td[@class='std']/ol[@onmouseover='return true']/li")
    results.each do |link|
      cite_link = link.css('cite').text.gsub(' ', '').gsub("\n", '')
      if cite_link.scan('http').first
        self.sponsored_cites << cite_link
      else
        self.sponsored_cites << "http://" + cite_link
      end
      self.ad_positions << 'Right'
    end
    self.sponsored_cites[0..number-1]
    
    results = doc.css("td[@class='std']/ol[@onmouseover='return true']/li/h3/a")
    results.each do |link|
      cite_link = self.adurl(link[:href])
      if cite_link.scan('http://').first
        self.sponsored_adurls << cite_link
      else
        self.sponsored_adurls << "http://" + cite_link
      end
    end
    
    self.sponsored_adurls[0..number-1]
  end
  
end