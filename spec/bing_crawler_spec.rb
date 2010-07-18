require File.expand_path(File.join(File.dirname(__FILE__),'..','bing_crawler'))

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
  end
end