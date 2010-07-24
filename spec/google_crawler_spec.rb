require File.expand_path(File.join(File.dirname(__FILE__),'..','google_crawler'))

describe "GoogleCrawler" do
  
  context "first search" do
    before(:each) do
      @page = File.read("spec/assets/google.html")
      @google_crawler = GoogleCrawler.new(@page)
    end
    
    it "should say the number of results" do
      @google_crawler.total_organic_results.should == '218000000'
    end

    it "should init a google crawler object" do
      @google_crawler.organic.class.should == Array
      @google_crawler.page.should == @page
      @google_crawler.sponsored_adurls.class.should == Array
    end

    it "should create an array of x urls of organic results on a page" do
      @google_crawler.organic_results(10).size.should == 8
      @google_crawler.organic.should == ["http://www.honda.com/", "http://powersports.honda.com/", "http://automobiles.honda.com/", "http://en.wikipedia.org/wiki/Honda", "http://www.hondapowerequipment.com/", "http://world.honda.com/", "http://www.honda-engines.com/", "http://marine.honda.com/"]
      @google_crawler.organic_results(8).size.should == 8
    end

    it "should create an array of all of the sponsored links" do
      @google_crawler.sponsored_results(5).size.should == 5
      @google_crawler.sponsored_adurls.should == ["http://automobiles.honda.com/", "http://www.obrienteamurbana.com/", "http://www.auto-price-finder.com/welcome", "http://www.autosite.com/system/cpcjump.cfm", "http://www.reply.com/portal/default.asp", "http://www.smartcycleshopper.com/honda-motorcycles.aspx"]
      @google_crawler.sponsored_results(7).size.should == 6
    end
    
    it "should store the positions of the ads" do
      @google_crawler.sponsored_results(10).size.should == 6
      @google_crawler.sponsored_cites.should == ["http://www.honda.com", "http://www.ObrienTeamUrbana.com", "http://Honda-Sale.Auto-Price-Finder.com", "http://Honda-2010-Clearance.Autosite.com", "http://Honda.Reply.com", "http://www.SmartCycleShopper.com/Honda"]
      @google_crawler.ad_positions.size.should == 6
      @google_crawler.ad_positions.should == ['Top', 'Right', 'Right', 'Right', 'Right', 'Right']
    end
  end

  context "second search using honda" do
    before(:each) do
      @page = File.read("spec/assets/honda.html")
      @google_crawler = GoogleCrawler.new(@page)
    end
    
    it "should create an array of x urls of organic results on a page" do
      @google_crawler.organic_results(5).size.should == 5
      @google_crawler.organic_results(8).size.should == 8 
    end
    
    it "should create an array of all of the sponsored links" do
      @google_crawler.sponsored_results(5).size.should == 3
      @google_crawler.sponsored_adurls.should == ["http://automobiles.honda.com/", "http://www.autosite.com/system/cpcjump.cfm", "http://www.reply.com/portal/default.asp"]
    end

  end
  
  context "testing sponsored links" do
    before(:each) do
      @page = File.read("spec/assets/honda.html")
      @google_crawler = GoogleCrawler.new(@page)
    end
    
    it "should use the adurl to determine the actual url" do
      link = "http://www.google.com/url?q=honda&url=/aclk%3Fsa%3DL%26ai%3DCsZY3ZThCTMCfG4b0MLKIkb0L4bz5zgGDt-z9EsysngYQASgDUM2dsaH-_____wFgycb-h_CjpBTIAQGqBBNP0Gnw_UI6v9Sq0dBDzJAY9Fmu%26num%3D2%26sig%3DAGiWqty9kgcOf0WFTy8YtYuio6fbgx3PgA%26adurl%3Dhttp://www.auto-price-finder.com/welcome%253Fid%253D289465091%2526creativeid%253D4999538733&rct=j&ei=ZThCTLuZGsXdnAelo-C-Dw&usg=AFQjCNGppI7_M8HNDZl6rhdRCbUZVUFP3w"
      @google_crawler.adurl(link).should == "www.auto-price-finder.com/welcome"
    end
    
    it "should use the adurl for the top most url as well" do
      link = "file:///aclk?sa=L&ai=C2axYzmkqTPaBG4TCNJTr4LgGwMjB2AGgnZOUFu301gUIABABILZUUNb6i-j-_____wFgycb-h_CjpBTIAQGqBBlP0A3Qo5eNP95Y5t3Qa0Zz1nIu62wA2kuzgAWQTg&sig=AGiWqtwpVFeU7I2wVgNZydRlbKaX6hH6-g&adurl=http://pixel1097.everesttech.net/1097/rq/3/s_abfa0108447ca729740d575c2e1aad7d_5853803352/url%3Dhttp%253A//automobiles.honda.com/"
      @google_crawler.adurl(link).should == "automobiles.honda.com/"
    end
  end
  
end