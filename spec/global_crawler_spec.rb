require File.expand_path(File.join(File.dirname(__FILE__),'..','global_crawler'))

describe "GlobalCrawler" do
  it "should process google results" do
    crawler = GlobalCrawler.new()
    page = File.read("spec/assets/google.html")
    google_results = crawler.google(page)
    google_results.organic.size.should == 10
    google_results.sponsored.size.should == 5
  end
end