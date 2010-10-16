require 'spec_helper'

describe "YahooCrawler" do
  context "generating the CSV file" do
    it "create the header row" do
      expected_row = ["Trademark", "Bing Total OL", "Bing Total SL", "Bing_OL0", "Bing_OL1", "Bing_OL2", "Bing_OL3", "Bing_OL4", "Bing_OL5", "Bing_OL6", "Bing_OL7", "Bing_OL8", "Bing_OL9", "Bing_SL0 Position", "Bing_SL0", "Bing_SL1 Position", "Bing_SL1", "Bing_SL2 Position", "Bing_SL2", "Bing_SL3 Position", "Bing_SL3", "Bing_SL4 Position", "Bing_SL4", "Bing_SL5 Position", "Bing_SL5", "Bing_SL6 Position", "Bing_SL6", "Bing_SL7 Position", "Bing_SL7", "Bing_SL8 Position", "Bing_SL8", "Bing_SL9 Position", "Bing_SL9", "Bing_SL10 Position", "Bing_SL10", "Bing_SL11 Position", "Bing_SL11", "Bing_SL12 Position", "Bing_SL12", "Bing_SL13 Position", "Bing_SL13", "Bing_SL14 Position", "Bing_SL14", "Google Total OL", "Google Total SL", "Google_OL0", "Google_OL1", "Google_OL2", "Google_OL3", "Google_OL4", "Google_OL5", "Google_OL6", "Google_OL7", "Google_OL8", "Google_OL9", "Google_SL0 Position", "Google_SL0", "Google_SL1 Position", "Google_SL1", "Google_SL2 Position", "Google_SL2", "Google_SL3 Position", "Google_SL3", "Google_SL4 Position", "Google_SL4", "Google_SL5 Position", "Google_SL5", "Google_SL6 Position", "Google_SL6", "Google_SL7 Position", "Google_SL7", "Google_SL8 Position", "Google_SL8", "Google_SL9 Position", "Google_SL9", "Google_SL10 Position", "Google_SL10", "Google_SL11 Position", "Google_SL11", "Google_SL12 Position", "Google_SL12", "Google_SL13 Position", "Google_SL13", "Google_SL14 Position", "Google_SL14", "Yahoo Total OL", "Yahoo Total SL", "Yahoo_OL0", "Yahoo_OL1", "Yahoo_OL2", "Yahoo_OL3", "Yahoo_OL4", "Yahoo_OL5", "Yahoo_OL6", "Yahoo_OL7", "Yahoo_OL8", "Yahoo_OL9", "Yahoo_SL0 Position", "Yahoo_SL0", "Yahoo_SL1 Position", "Yahoo_SL1", "Yahoo_SL2 Position", "Yahoo_SL2", "Yahoo_SL3 Position", "Yahoo_SL3", "Yahoo_SL4 Position", "Yahoo_SL4", "Yahoo_SL5 Position", "Yahoo_SL5", "Yahoo_SL6 Position", "Yahoo_SL6", "Yahoo_SL7 Position", "Yahoo_SL7", "Yahoo_SL8 Position", "Yahoo_SL8", "Yahoo_SL9 Position", "Yahoo_SL9", "Yahoo_SL10 Position", "Yahoo_SL10", "Yahoo_SL11 Position", "Yahoo_SL11", "Yahoo_SL12 Position", "Yahoo_SL12", "Yahoo_SL13 Position", "Yahoo_SL13", "Yahoo_SL14 Position", "Yahoo_SL14"]
      computed_row = Trademark.csv_header
      computed_row.should == expected_row
    end
    
    it "should generate a CSV row for a trademark" do
      trademark = Trademark.create(:complete => true, :term => "Ruby on Rails", :total_google_results => 1, :total_yahoo_results => 2, :total_bing_results => 3)
      6.times   {|i| trademark.search_results.create(:url => "http://www.google.com#{i}", :search_engine => "Yahoo")}
      8.times   {|i| trademark.search_results.create(:url => "http://www.google.com#{i}", :search_engine => "Google")}
      10.times  {|i| trademark.search_results.create(:url => "http://www.google.com#{i}", :search_engine => "Bing")}
      
      6.times   {|i| trademark.search_ads.create(:url => "http://ad_url#{i}.com", :search_engine => "Yahoo", :location => "Top")}
      2.times   {|i| trademark.search_ads.create(:url => "http://ad_url#{i}.com", :search_engine => "Google", :location => "Bottom")}
      4.times   {|i| trademark.search_ads.create(:url => "http://ad_url#{i}.com", :search_engine => "Bing", :location => "Right")}
    
    
      
      trademark.csv_row.should == ["Ruby on Rails", "3", "4", "http://www.google.com0", "http://www.google.com1", "http://www.google.com2", "http://www.google.com3", "http://www.google.com4", "http://www.google.com5", "http://www.google.com6", "http://www.google.com7", "http://www.google.com8", "http://www.google.com9", "Right", "http://ad_url0.com", "Right", "http://ad_url1.com", "Right", "http://ad_url2.com", "Right", "http://ad_url3.com", "", "", "", "", "", "", "", "", "", "", "", "1", "2", "http://www.google.com0", "http://www.google.com1", "http://www.google.com2", "http://www.google.com3", "http://www.google.com4", "http://www.google.com5", "http://www.google.com6", "http://www.google.com7", "", "", "Bottom", "http://ad_url0.com", "Bottom", "http://ad_url1.com", "", "", "", "", "", "", "", "", "", "", "", "", "", "2", "6", "http://www.google.com0", "http://www.google.com1", "http://www.google.com2", "http://www.google.com3", "http://www.google.com4", "http://www.google.com5", "", "", "", "", "Top", "http://ad_url0.com", "Top", "http://ad_url1.com", "Top", "http://ad_url2.com", "Top", "http://ad_url3.com", "Top", "http://ad_url4.com", "Top", "http://ad_url5.com", "", "", "", "", "", "", "", "", ""]
    
    end
  end
end