require 'global_crawler'
require 'action_pack'

# puts ARGV.first

c = GlobalCrawler.new
c.start

# c = GlobalCrawler.new
# g = c.search_google('honda')
# 
# puts "Organic Search Results\n"
# puts "-------------------------"
# g.organic_results(10).each do |link|
#   puts link
# end
# 
# puts "\n"
# puts "Sponsored Search Results\n"
# puts "-------------------------"
# g.sponsored_results(10).each do |link|
#   puts link
# end