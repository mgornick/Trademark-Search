require File.expand_path(File.join(File.dirname(__FILE__),'..','global_crawler'))

describe "GlobalCrawler" do
  it "should only include alphanumeric characters in the trademark" do
    GlobalCrawler.clean_trademark("AbCD EFG 123").should == "AbCDEFG123"
    GlobalCrawler.clean_trademark("a!@$%^&*(),./?~`b\\").should == "ab"
  end
end
