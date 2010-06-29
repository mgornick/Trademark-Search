require 'rubygems'
require 'capybara'
require 'capybara/dsl'

# Capybara.current_driver = :culerity
# Capybara.app_host = 'http://www.google.com'
# Capybara.visit('/')
# Capybara.fill_in "q", :with => 'Honda'
# Capybara.click 'Google Search'
# puts Capybara.page.body

Capybara.current_driver = :culerity
Capybara.app_host = 'http://www.bing.com'
Capybara.visit('http://www.bing.com/search?q=honda')
puts Capybara.page.body