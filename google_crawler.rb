require 'rubygems'
require 'nokogiri'
require 'pdfkit'

class GoogleCrawler
  attr_accessor :organic, :sponsored, :page, :sponsored_cite
  
  def initialize(webpage)
    self.organic = []
    self.sponsored = []
    self.sponsored_cite = []
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
  
  def adurl(link) #regex to try an extract the resulting adurl from the sponsored link
    link.scan(/[\w|\d|\-|.]*\.[\w]{3,4}[\/|\w|\d|\-]*[.|\w]*/).last
  end
  
  def sponsored_results(number)
    self.sponsored = []
    self.sponsored_cite = []
    doc = Nokogiri::HTML(page) # let nokogiri parse the DOM
    
    # grabbing the cite tag
    results = doc.css("ol[@onmouseover='return true']/li")
    results.each do |link|
      cite_link = link.css('cite').text.gsub(' ', '').gsub("\n", '')
      if cite_link.scan('http').first
        self.sponsored_cite << cite_link
      else
        self.sponsored_cite << "http://" + cite_link
      end
    end
    
    results = doc.css("ol[@onmouseover='return true']/li/h3/a")
    results.each do |link|
      cite_link = self.adurl(link[:href])
      if cite_link.scan('http://').first
        self.sponsored << cite_link
      else
        self.sponsored << "http://" + cite_link
      end
    end
    self.sponsored[0..number-1]
  end
  
end