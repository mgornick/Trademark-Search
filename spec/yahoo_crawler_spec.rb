require File.expand_path(File.join(File.dirname(__FILE__),'..','yahoo_crawler'))

describe "YahooCrawler" do
  context "when parsing ads" do
    before(:each) do
      @page = File.read("spec/assets/yahoo.html")
      @yahoo_crawler = YahooCrawler.new(@page)
    end
    
    it "should get the number of results" do
      @yahoo_crawler.total_organic_results.should == '157,000,000'
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
  
  context "second test of parsing ads" do
    before(:each) do
      @page = File.read("spec/assets/armani.html")
      @yahoo_crawler = YahooCrawler.new(@page)
    end
    
    it "should store the position of the ads" do
      @yahoo_crawler.sponsored_results(10)
      @yahoo_crawler.sponsored_cites.should == ["http://www.sephora.com/giorgioarmani", "http://www.emporioarmaniwatches.com", "http://www.saksfifthavenue.com/armani", "http://www.nordstrom.com/armani_collezioni", "http://www.ebay.com", "http://perfumeangel.com", "http://giorgioarmanibeauty-usa.com", "http://shopzilla.com/giorgioarmani", "http://www.nordstrom.com/armani_collezioni", "http://www.ebay.com"]
      @yahoo_crawler.ad_positions.should == ['Top', 'Top', 'Top', 'Right', 'Right', 'Right', 'Right', 'Right', 'Bottom', 'Bottom']
    end
    
  end
end