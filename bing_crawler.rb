require 'rubygems'
require 'nokogiri'

class BingCrawler
  attr_accessor :organic, :page, :sponsored_cites, :sponsored_adurls
  
  def initialize(webpage)
    self.organic = []
    self.sponsored_adurls = []
    self.sponsored_cites = []
    self.page = webpage
  end


  def organic_results(number)
    self.organic = []
    doc = Nokogiri::HTML(page) # let nokogiri parse the DOM
    
    results = doc.css("div[@id='results']/ul[@class='sb_results']/li/div[@class='sa_cc']/div[@class='sb_tlst']/h3/a")
    results.each do |link|
      self.organic << link[:href]
    end
    
    self.organic[0..number-1]
  end
  
  def adurl(link) #regex to try an extract the resulting adurl from the sponsored link
    link.scan(/[\w|\d|\-|.]*\.[\w]{3,4}[\/|\w|\d|\-]*[.|\w]*/).last
  end
  
  def sponsored_results(number)
    self.sponsored_adurls = []
    self.sponsored_cites = []
    
    doc = Nokogiri::HTML(page) # let nokogiri parse the DOM
    
    # grabbing the cite tag
    results = doc.css("ul[@onmouseover='return true']/li/div[@class='sb_add sb_adN']/cite")
    results.each do |cite_link|
        self.sponsored_cites << "http://" + cite_link
        puts "Found cite: " + cite_link
    end
    self.sponsored_cites[0..number-1]
    
    results = doc.css("ul[@onmouseover='return true']/li/div[@class='sb_add sb_adN']/h3/a")
    results.each do |link|
      self.sponsored_adurls << link[:href]
    end
    
    self.sponsored_adurls[0..number-1]
  end
  
end