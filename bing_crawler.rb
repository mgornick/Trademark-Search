require 'rubygems'
require 'nokogiri'

class BingCrawler
  attr_accessor :organic, :page, :sponsored_cites, :ad_positions
  
  def initialize(webpage)
    self.organic = []
    self.sponsored_cites = []
    self.ad_positions = []
    self.page = webpage
  end
  
  def total_organic_results
    self.page.scan(/[0-9|,]+ results/).first.split.first
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
    self.sponsored_cites = []
    self.ad_positions = []
    
    doc = Nokogiri::HTML(page) # let nokogiri parse the DOM
    
    # grabbing the cite tag
    top_results = doc.css("div[@class='sb_adsWv2']/ul[@onmouseover='return true']/li/div[@class='sb_add sb_adW']/cite")
    top_results.each do |link|
      cite_link = self.remove_html(link.to_s)
      cite_link = cite_link.gsub(' ', '').gsub("\n", '').gsub("\r", '').gsub("\t",'').downcase
      if cite_link.scan('http').first
        self.sponsored_cites << cite_link
      else
        self.sponsored_cites << "http://" + cite_link
      end
      ad_positions << 'Top'
    end
    
    right_results = doc.css("div[@class='sb_adsNv2']/ul[@onmouseover='return true']/li/div[@class='sb_add sb_adN']/cite")
    right_results.each do |link|
      cite_link = self.remove_html(link.to_s)
      cite_link = cite_link.gsub(' ', '').gsub("\n", '').gsub("\r", '').gsub("\t",'').downcase
      if cite_link.scan('http').first
        self.sponsored_cites << cite_link
      else
        self.sponsored_cites << "http://" + cite_link
      end
      ad_positions << 'Right'
    end
    
    bottom_results = doc.css("div[@class='sb_adsWv2 sb_adsW2v2']/ul[@onmouseover='return true']/li/div[@class='sb_add sb_adW']/cite")
    bottom_results.each do |link|
      cite_link = self.remove_html(link.to_s)
      cite_link = cite_link.gsub(' ', '').gsub("\n", '').gsub("\r", '').gsub("\t",'').downcase
      if cite_link.scan('http').first
        self.sponsored_cites << cite_link
      else
        self.sponsored_cites << "http://" + cite_link
      end
      ad_positions << 'Bottom'
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