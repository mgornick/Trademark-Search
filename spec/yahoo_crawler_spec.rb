require File.expand_path(File.join(File.dirname(__FILE__),'..','yahoo_crawler'))

describe "YahooCrawler" do
  context "when parsing ads" do
    before(:each) do
      @page = File.read("spec/assets/yahoo.html")
      @yahoo_crawler = YahooCrawler.new(@page)
    end
    
    # it "should retrieve the ad urls" do
    #   @yahoo_crawler.sponsored_results(10)
    #   @yahoo_crawler.sponsored_adurls.size.should == 6
    # end
    
    it "should retrieve the cite urls" do
      @yahoo_crawler.sponsored_results(10)
      @yahoo_crawler.sponsored_cites.size.should == 6
    end
    
    it "should store the position of the ads" do
      @yahoo_crawler.sponsored_results(10)
      @yahoo_crawler.sponsored_cites.should == ["http://store.apple.com", "http://www.nextag.com/apple", "http://dominicks.com", "http://www.dealtime.com", "http://www.nextag.com/apple", "http://dominicks.com"]
      @yahoo_crawler.ad_positions.should == ['Top', 'Right', 'Right', 'Right', 'Bottom', 'Bottom']
    end
  end
end