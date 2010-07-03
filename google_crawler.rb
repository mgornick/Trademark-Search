require 'rubygems'
require 'nokogiri'

class GoogleCrawler
  attr_accessor :organic, :sponsored, :page
  
  def initialize(webpage)
    self.organic = []
    self.sponsored = []
    self.page = webpage
  end

  def organic_results(number)
    self.organic = []
    doc = Nokogiri::HTML(page) # let nokogiri parse the DOM
    
    results = doc.css("div[@id='ires']/ol/li[@class='g']/h3[@class='r']/a[@class='l']")
    results.each do |link|
      self.organic << link[:href]
    end
    
    self.organic[0..number-1]
  end
  
  def sponsored_results(number)
    self.sponsored = []
    doc = Nokogiri::HTML(page) # let nokogiri parse the DOM
    
    results = doc.css("ol[@onmouseover='return true']/li")
    results.each do |link|
      self.sponsored << link.css('cite').text.gsub(' ', '').gsub("\n", '')
    end
    
    self.sponsored[0..number-1]
  end
  
end