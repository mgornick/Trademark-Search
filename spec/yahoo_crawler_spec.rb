require File.expand_path(File.join(File.dirname(__FILE__),'..','yahoo_crawler'))

describe "YahooCrawler" do
  context "when parsing ads" do
    before(:each) do
      @page = File.read("spec/assets/armani.html")
      @yahoo_crawler = YahooCrawler.new(@page)
    end
    
    it "should get the number of results" do
      @yahoo_crawler.total_organic_results.should == '200002828' 
    end
  
    
    it "should retrieve the cite urls" do
      @yahoo_crawler.sponsored_results(15)
      @yahoo_crawler.sponsored_cites.size.should == 12
    end
    
    it "should store the position of the ads" do
      @yahoo_crawler.sponsored_results(15)
      @yahoo_crawler.sponsored_cites.should == ["http://www.nordstrom.com", "http://giorgioarmanibeauty-usa.com","http://www.saksfifthavenue.com/armani", "http://www.popularglasses.com/earmani", "http://www.perfumania.com", "http://www.watchrepairsusa.com", "http://www.target.com", "http://www.shopnbc.com", "http://www.strawberrynet.com/giorgioarmani", "http://www.eyewearus.com/giorgioarmani", "http://www.saksfifthavenue.com/armani", "http://www.popularglasses.com/earmani"]
      @yahoo_crawler.ad_positions.should == ['Top', 'Top', 'Right', 'Right', 'Right', 'Right', 'Right', 'Right', 'Right', 'Right', 'Bottom', 'Bottom']
    end
  end
end