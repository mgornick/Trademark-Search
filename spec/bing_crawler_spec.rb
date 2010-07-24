require File.expand_path(File.join(File.dirname(__FILE__),'..','bing_crawler'))
require 'pdfkit'

describe "BingCrawler" do
  context "when parsing ads" do
    before(:each) do
      @page = File.read("spec/assets/bing.html")
      @bing_crawler = BingCrawler.new(@page)
    end
    
    it "should get the number of results" do
      @bing_crawler.total_organic_results.should == "157,000,000"
    end
    
    it "should retrieve the cite urls" do
      @bing_crawler.sponsored_results(10)
      @bing_crawler.sponsored_cites.size.should == 6
      @bing_crawler.sponsored_cites.should == ["http://www.honda.com", "http://www.whypaysticker.com/honda", "http://honda.autodiscountgroup.com", "http://www.smartautosavings.com", "http://honda.carpricesecrets.com", "http://www.honda.com"]
    end
    
    it "should style the html page of bing" do
      html = File.read("spec/assets/bing.html")
      index = html.rindex('.sa_cpt{position:absolute}')
      
      converted_html = @bing_crawler.convert_absolute_to_static(html, index)
      pdf = PDFKit.new(html)
      pdf.to_file('spec/assets/bing.pdf')
    end
    
    it "should determine the location of ads" do
      @bing_crawler.sponsored_results(10)
      @bing_crawler.sponsored_cites.size.should == 6
      @bing_crawler.ad_positions.size.should == 6
      @bing_crawler.ad_positions.should == ['Top', 'Right','Right','Right','Right','Bottom']
    end
  end
end