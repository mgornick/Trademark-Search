#Trademark Search

##Purpose
Professor David Hyman wants to do a search for a trademark on Google, Bing, and Yahoo and get the top organic search results and the top sponsored links (limit 5 - 10 for each).  In the end he wants an Excel file will all of these results organized as well as a 'screenshot' of the search results page as well as each of the organic search and sponsored links.

##Requirements
Be sure to install wkhtmltopdf if you need to export PDF's of the webpages. Follow tutorial on [Github](https://github.com/jdpace/PDFKit/wiki/Installing-WKHTMLTOPDF)

Setup/Install ruby gems by using:
gem install bundler
bundle install


##Instructions

Run the scraper:

1. Enter the Rails Console by running:
  script/console

2. Import Trademarks from the trademarks.txt file

  Trademark.import

3. Search Google, Yahoo, and Bing for those search terms

  Trademark.scrape

4. Compute where the organic links and sponsored links are on each page

  Trademark.links

5. (optional) Export all search result pages to PDF in the "TRADEMARKS/" folder

  Trademark.pdfs


##Code Overview

- Read a text file (trademarks.txt) that has each trademark on a new line
- For each trademark:
  - Run a search in Google
      - Get the top organic search results
      - Get the top x sponsored links
      - Put screen shot into a folder
      - Put urls to results into a CSV (for excel)
  - Run a search in Bing
      - Get the top organic search results
      - Get the top x sponsored links
      - Put screen shot into a folder
      - Put urls to results into a CSV (for excel)
  - Run a search in Yahoo
      - Get the top organic search results
      - Get the top x sponsored links
      - Put screen shot into a folder
      - Put urls to results into a CSV (for excel)

#Usage
- modify the trademarks.txt file with the search terms you want to run
- type: ruby runner.rb
- a trademark_results.csv file will be created along with folders representing the trademarks

#Required Gems and Libraries
PDFKit
Capybara
Nokogiri
wkhtmltopdf
