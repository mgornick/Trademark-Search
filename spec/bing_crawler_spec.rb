require File.expand_path(File.join(File.dirname(__FILE__),'..','bing_crawler'))
require 'pdfkit'

describe "BingCrawler" do
  context "when parsing ads" do
    before(:each) do
      @page = File.read("spec/assets/bing.html")
      @bing_crawler = BingCrawler.new(@page)
    end
    
    it "should retrieve the cite urls" do
      @bing_crawler.sponsored_results(10)
      @bing_crawler.sponsored_cites.size.should == 6
      puts @bing_crawler.sponsored_cites.inspect
    end
    
    it "should style the html page of bing" do
      html = File.read("spec/assets/bing.html")
      index = html.rindex('.sa_cpt{position:absolute}')
      
      converted_html = @bing_crawler.convert_absolute_to_static(html, index)
      puts converted_html.scan(/.sa_cpt{position:[a-z]*}/)
      pdf = PDFKit.new(html)
      pdf.to_file('spec/assets/bing.pdf')
    end
  end
end