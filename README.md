# Indigo Flight Traffic & Passenger Analysis

## Project Overview
- This project is an end-to-end SQL data analysis that explores flight patterns, passenger volumes, and airport traffic. By designing a normalized relational database and migrating raw metadata into structured tables, this project extracts meaningful business insights regarding high-traffic flight corridors, top-performing airports, and the correlation between city population and air travel frequency.

## Database Architecture
- The project transforms flat metadata into a robust, normalized relational database (Flight_Analysis) containing five primary tables:
   - Airline: Stores unique carrier details and IDs.
   - Airport: Contains detailed geographical and categorical data for all airports (origins and destinations).
   - Flight: The central fact table linking airlines, origins, destinations, and flight dates/distances.
   - FlightMetrics: Stores numerical data related to payload, including passenger counts, freight, and mail per flight.
   - City: A dedicated table for city demographics, later integrated with external population data to calculate travel ratios.

## Key Analytical Highlights
- This analysis uncovers several critical business metrics:

### 1. Route-Wise Flight Analysis
- Identifies the top 10 busiest flight routes based on total passenger volume.
- Determines high-traffic business corridors by calculating the raw frequency of flights between specific origin and destination pairs (e.g., highlighting routes involving Los Angeles).

### 2. Passenger Volume Trends
- Time-Series Tracking: Calculates the total passengers served over time, grouped by year and month (in millions) to identify seasonal travel trends.
- Averages by City: Evaluates the average number of passengers per flight for both origin and destination cities, helping identify which cities operate the most packed flights.

### 3. Top Performing Airports
- Aggregates total flights and total passengers to rank the busiest origin and destination hubs.

### 4. Demographic Correlation (Population vs. Traffic)
- Integrates external demographic data to analyze the relationship between a city's population and its air traffic.
- Calculates a custom Passenger-to-Population Ratio (Pass_Pop_Ratio) to identify cities that see a disproportionately high amount of air travel compared to their resident population.

## Advanced SQL Techniques Utilized
- This project goes beyond basic SELECT statements, showcasing advanced database management skills:
   - Data Normalization & Ingestion: INSERT INTO ... SELECT statements to clean and distribute raw MetaData into interconnected tables with Primary and Foreign Keys.
   - Data Cleaning: Using functions like SUBSTRING_INDEX and turning off SQL_Safe_Updates to standardize city names by removing unwanted commas and formatting artifacts.
   - Complex Joins: Utilizing INNER JOIN and LEFT JOIN across up to four tables simultaneously to connect demographic, geographic, and flight metric data.
   - Views: Created virtual tables (Pass_Pop_Des and Pass_Pop_Ori) to permanently save complex queries related to the passenger-to-population ratio for easy future querying.
   - Stored Procedures: * traffic(): Instantly calls overall destination traffic.
   - State_level_traffic(State): Accepts a state name as an input parameter to filter traffic data dynamically (e.g., calculating traffic specifically for "Alaska").
   - sp_top_routes_by_passenger(threshold): Accepts a numerical input to dynamically filter routes that exceed a specific passenger threshold.

## How to Use
- Execute the script in a MySQL environment.
- Ensure your raw data is imported into the MetaData and all_city_pop tables first.
- Run the table creation and INSERT block to normalize the database.
- Execute the SELECT queries sequentially to view the analysis.
- Use the CALL commands at the bottom of the script to test the interactive Stored Procedures.
