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
  
  def convert_absolute_to_static(html, index)
    start = index + 17
    html[start]   = 's'
    html[start+1] = 't'
    html[start+2] = 'a'
    html[start+3] = 't'
    html[start+4] = 'i'
    html[start+5] = 'c'
    html[start+6] = ''
    html[start+6] = ''
    html
  end


  def organic_results(number)
    self.organic = []
    doc = Nokogiri::HTML(page) # let nokogiri parse the DOM
    
    results = doc.css("div[@id='results']/ul[@class='sb_results']/li/div[@class='sa_cc']/div[@class='sb_tlst']/h3/a")
    results.each do |link|
      self.organic << link[:href]
    end
    
    self.organic = self.organic[0..number-1]
  end
  
  def adurl(link) #regex to try an extract the resulting adurl from the sponsored link
    link.scan(/[\w|\d|\-|.]*\.[\w]{3,4}[\/|\w|\d|\-]*[.|\w]*/).last
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
    self.sponsored_adurls = []
    self.sponsored_cites = []
    
    doc = Nokogiri::HTML(page) # let nokogiri parse the DOM
    
    # grabbing the cite tag
    results = doc.css("ul[@onmouseover='return true']/li/div/cite")
    results.each do |link|
      cite_link = self.remove_html(link.to_s)
      cite_link = cite_link.gsub(' ', '').gsub("\n", '').gsub("\r", '').gsub("\t",'').downcase
      if cite_link.scan('http').first
        self.sponsored_cites << cite_link
      else
        self.sponsored_cites << "http://" + cite_link
      end
    end
    self.sponsored_cites = self.sponsored_cites[0..number-1]
    
    # results = doc.css("ul[@onmouseover='return true']/li/div[@class='sb_add sb_adN']/h3/a")
    # results.each do |link|
    #   self.sponsored_adurls << link[:href]
    # end
    # 
    # self.sponsored_adurls[0..number-1]
  end
  
end