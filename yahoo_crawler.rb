require 'rubygems'
require 'nokogiri'

class YahooCrawler
  attr_accessor :organic, :sponsored_adurls, :page, :sponsored_cites
  
  def initialize(webpage)
    self.organic = []
    self.sponsored_adurls = []
    self.sponsored_cites = []
    self.page = webpage
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
    self.sponsored_adurls = []
    doc = Nokogiri::HTML(page) # let nokogiri parse the DOM
    
    results = doc.css("li/em")
    results.each do |link|
      cite_link = self.remove_html(link.to_s)
      if !cite_link.include?("sign in")
        cite_link = cite_link.gsub(' ', '').gsub("\n", '').gsub("\r", '').gsub("\t",'').downcase
        if cite_link.scan('http').first
          self.sponsored_cites << cite_link
        else
          self.sponsored_cites << "http://" + cite_link
        end
      end
    end
    self.sponsored_cites = self.sponsored_cites[0..number-1]
  end
  
end