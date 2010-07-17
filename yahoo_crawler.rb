require 'rubygems'
require 'nokogiri'

class YahooCrawler
  attr_accessor :organic, :sponsored, :page
  
  def initialize(webpage)
    self.organic = []
    self.sponsored = []
    self.page = webpage
  end

  def organic_results(number)
    self.organic = []
    doc = Nokogiri::HTML(page) # let nokogiri parse the DOM
    
    results = doc.css("div[@id='web']/ol/li/div[@class='res']/div/h3/a")
    results.each do |link|
      self.organic << link[:href]
    end
    
    self.organic[0..number-1]
  end
  
  def sponsored_results(number)
    self.sponsored = []
    doc = Nokogiri::HTML(page) # let nokogiri parse the DOM
    
    results = doc.css("div[@id='right']/div[@id='east']/ul/li/a")
    results.each do |link|
      self.sponsored << link[:href]
    end
    
    self.sponsored[0..number-1]
  end
  
end