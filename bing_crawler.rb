require 'rubygems'
require 'nokogiri'

class BingCrawler
  attr_accessor :organic, :sponsored, :page
  
  def initialize(webpage)
    self.organic = []
    self.sponsored = []
    self.page = webpage
  end

  def organic_results(number)
    self.organic = []
    doc = Nokogiri::HTML(page) # let nokogiri parse the DOM
    
    results = doc.css("div[@id='results']/ul/li[@class='sa_cc']/div[@class='sb_tlst']/h3/a")
    results.each do |link|
      self.organic << link[:href]
    end
    
    self.organic[0..number-1]
  end
  
  def sponsored_results(number)
    self.sponsored = []
    doc = Nokogiri::HTML(page) # let nokogiri parse the DOM
    
    results = doc.css("div[@id='sidebar']/ul[@onmouseover='return true']/li/div[@class='sb_add sb_adN']/h3/a")
    results.each do |link|
      self.sponsored << link[:href]
    end
    
    self.sponsored[0..number-1]
  end
  
end