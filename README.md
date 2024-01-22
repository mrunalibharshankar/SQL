# Famous Painting and Artist Details in SQL and Tableau

# Overview
This dataset is about Famous Paintings with museums it is displayed and Artist. The Data is in 8 different tables with following names:
1. artist.csv
2. canvas_size.csv
3. image_link.csv
4. museum_hours.csv
5. museum.csv
6. product_size
7. subject.csv
8. work.csv

The original files were exported from the [data.world](https://data.world/atlas-query/paintings), and are available in this repository as an csv files.

The goal was to find out the meaning insights from the given data.

The data contained 100,000+ records in total.

# Data Cleaning in Excel
- Data contained duplicate and some incorrect values.
- It had Regex had to rename it. Some columns had missing value about location such as state and city.

# SQL Queries
- Loaded data 8 tables into Mysql server with [Python](https://github.com/mrunalibharshankar/SQL/blob/70bada1a623d7b7edf0c41cf85bd6b5aae13a018/load_csv_files.py)
- In Mysql, used Joins, CTE, Windows function to find out the insights about the data.
  
[SQL Output](https://github.com/mrunalibharshankar/SQL/blob/c84d9cc299a8fbfe7432c4ca2fdcb4a2f787eec9/paintings_queries.sql)

# Data Visualization in Tableau
- The Dashboard contained the worksheets about,
  1. KPI
  2. Artist and Painting name Details
  3. Painting Prices
  4. Painting Subjects
  5. Museum Name, Address and Phone number
  6. Filters on Countries, Affordability and Opening/Closing hours of museums with Day.


[Tableau Dashboard](https://public.tableau.com/app/profile/mrunali.bharshankar/viz/FamousPaintingandArtistDetailsDashboard1/FamousPaintingsandArtistsDetails)


















