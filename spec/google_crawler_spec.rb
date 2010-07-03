require File.expand_path(File.join(File.dirname(__FILE__),'..','google_crawler'))

describe "GoogleCrawler" do
  
  context "first search" do
    before(:each) do
      @page = File.read("spec/assets/google.html")
      @google_crawler = GoogleCrawler.new(@page)
    end

    it "should init a google crawler object" do
      @google_crawler.organic.class.should == Array
      @google_crawler.page.should == @page
      @google_crawler.sponsored.class.should == Array
    end

    it "should create an array of x urls of organic results on a page" do
      @google_crawler.organic_results(5).size.should == 5
      @google_crawler.organic.should == ["http://www.honda.com/", "http://powersports.honda.com/", "http://automobiles.honda.com/", "http://en.wikipedia.org/wiki/Honda", "http://www.hondapowerequipment.com/", "http://world.honda.com/", "http://www.honda-engines.com/", "http://marine.honda.com/"]
      @google_crawler.organic_results(8).size.should == 8
    end

    it "should create an array of all of the sponsored links" do
      @google_crawler.sponsored_results(5).size.should == 5
      @google_crawler.sponsored.should == ["www.honda.com", "www.ObrienTeamUrbana.com", "Honda-Sale.Auto-Price-Finder.com", "Honda-2010-Clearance.Autosite.com", "Honda.Reply.com", "www.SmartCycleShopper.com/Honda"]
      @google_crawler.sponsored_results(7).size.should == 6
    end
  end

  context "second search" do
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
      @google_crawler.sponsored.should == ["www.honda.com", "www.ObrienTeamUrbana.com", "Honda-Sale.Auto-Price-Finder.com", "Honda-2010-Clearance.Autosite.com", "Honda.Reply.com", "www.SmartCycleShopper.com/Honda"]
    end
  end
  
end