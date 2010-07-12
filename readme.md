#Trademark Search

##Purpose
Professor Hyman (?) wants to do a search for a trademark on Google, Bing, and Yahoo and get the top organic search results and the top sponsored links (limit 5 - 10 for each).  In the end he wants an Excel file will all of these results organized as well as a 'screenshot' of the search results page as well as each of the organic search and sponsored links.

##Code Overview
Basically the purpose of the code is to do the following:

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
    
#Helpful Hints