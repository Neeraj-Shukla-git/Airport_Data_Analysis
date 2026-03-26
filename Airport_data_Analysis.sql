# INDIGO FLIGHT DELAY ANALYSIS

# Create Database
create database Flight_Analysis;

# Use Database
use Flight_Analysis;

# Import CSV data like meta_data & 
# Go to Table than write Click Table data import wizard

# Show Data
select * from meta_data;

# Drop Database if you want 
drop database Flight_Analysis;

# Create this tables Airport, Flight, FlightMetrics, City

CREATE TABLE Airline (
    AIRLINE_ID INT PRIMARY KEY,
    UNIQUE_CARRIER VARCHAR(10),
    UNIQUE_CARRIER_NAME VARCHAR(100),
    UNIQUE_CARRIER_ENTITY VARCHAR(10)
);

select * from Airline;

CREATE TABLE Airport (
    AIRPORT_ID INT PRIMARY KEY,
    AIRPORT_SEQ_ID INT,
    CITY_MARKET_ID INT,
    AIRPORT_CODE VARCHAR(10),
    CITY_NAME VARCHAR(100),
    STATE_ABR CHAR(2),
    STATE_FIPS INT,
    STATE_NM VARCHAR(100),
    WAC INT
);

select * from Airport;

CREATE TABLE Flight (
    FLIGHT_ID INT AUTO_INCREMENT PRIMARY KEY,
    AIRLINE_ID INT,
    ORIGIN_AIRPORT_ID INT,
    DEST_AIRPORT_ID INT,
    DISTANCE FLOAT,
    DISTANCE_GROUP INT,
    YEAR INT,
    QUARTER INT,
    MONTH INT,
    CLASS CHAR(1),
    FOREIGN KEY (AIRLINE_ID) REFERENCES Airline(AIRLINE_ID),
    FOREIGN KEY (ORIGIN_AIRPORT_ID) REFERENCES Airport(AIRPORT_ID),
    FOREIGN KEY (DEST_AIRPORT_ID) REFERENCES Airport(AIRPORT_ID)
);

select * from Flight;

CREATE TABLE FlightMetrics (
    FLIGHT_ID INT,
    PASSENGERS FLOAT,
    FREIGHT FLOAT,
    MAIL FLOAT,
    FOREIGN KEY (FLIGHT_ID) REFERENCES Flight(FLIGHT_ID)
);

select * from FlightMetrics;

CREATE TABLE City (
	City_id INT AUTO_INCREMENT PRIMARY KEY,
    CityName VARCHAR(100),
    STATE_ABR CHAR(2),
    State_NM varchar(100) 
);

select * from city;

# Data Insertion

INSERT INTO Airline (AIRLINE_ID, UNIQUE_CARRIER, UNIQUE_CARRIER_NAME, UNIQUE_CARRIER_ENTITY)
SELECT DISTINCT
    AIRLINE_ID,
    UNIQUE_CARRIER,
    UNIQUE_CARRIER_NAME,
    UNIQUE_CARRIER_ENTITY
FROM MetaData;

select distinct airline_id from airline;
select * from meta_data;

select * from airport;

INSERT INTO Airport (
    AIRPORT_ID, AIRPORT_SEQ_ID, CITY_MARKET_ID, AIRPORT_CODE,
    CITY_NAME, STATE_ABR, STATE_FIPS, STATE_NM, WAC
)
SELECT DISTINCT
    ORIGIN_AIRPORT_ID,
    ORIGIN_AIRPORT_SEQ_ID,
    ORIGIN_CITY_MARKET_ID,
    ORIGIN,
    ORIGIN_CITY_NAME,
    ORIGIN_STATE_ABR,
    ORIGIN_STATE_FIPS,
    ORIGIN_STATE_NM,
    ORIGIN_WAC
FROM MetaData

UNION

SELECT DISTINCT
    DEST_AIRPORT_ID,
    DEST_AIRPORT_SEQ_ID,
    DEST_CITY_MARKET_ID,
    DEST,
    DEST_CITY_NAME,
    DEST_STATE_ABR,
    DEST_STATE_FIPS,
    DEST_STATE_NM,
    DEST_WAC
FROM MetaData;


INSERT INTO Flight (
    AIRLINE_ID, ORIGIN_AIRPORT_ID, DEST_AIRPORT_ID,
    DISTANCE, DISTANCE_GROUP,
    YEAR, QUARTER, MONTH, CLASS
)
SELECT
    AIRLINE_ID,
    ORIGIN_AIRPORT_ID,
    DEST_AIRPORT_ID,
    DISTANCE,
    DISTANCE_GROUP,
    YEAR,
    QUARTER,
    MONTH,
    CLASS
FROM MetaData;

select * from flight;


INSERT INTO FlightMetrics (
    FLIGHT_ID, PASSENGERS, FREIGHT, MAIL
)
SELECT
    f.FLIGHT_ID,
    m.PASSENGERS,
    m.FREIGHT,
    m.MAIL
FROM MetaData m
JOIN Flight f
  ON f.AIRLINE_ID = m.AIRLINE_ID
 AND f.ORIGIN_AIRPORT_ID = m.ORIGIN_AIRPORT_ID
 AND f.DEST_AIRPORT_ID = m.DEST_AIRPORT_ID
 AND f.YEAR = m.YEAR
 AND f.MONTH = m.MONTH
 AND f.QUARTER = m.QUARTER
 AND f.DISTANCE = m.DISTANCE;

select * from flight;


INSERT INTO City (CityName, STATE_ABR, State_NM)
SELECT DISTINCT
    CITY_NAME,
    STATE_ABR,
    STATE_NM
FROM Airport;

select * from city;


### Data Analysis

### Route wise Flight analysis

SELECT 
    f.ORIGIN_AIRPORT_ID,
    f.DEST_AIRPORT_ID,
    a1.CITY_NAME AS ORIGIN_CITY,
    a2.CITY_NAME AS DEST_CITY,
    SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS
FROM Flight f
JOIN Flightmetrics fm ON f.FLIGHT_ID = fm.FLIGHT_ID
JOIN Airport a1 ON f.ORIGIN_AIRPORT_ID = a1.AIRPORT_ID
JOIN Airport a2 ON f.DEST_AIRPORT_ID = a2.AIRPORT_ID
GROUP BY f.ORIGIN_AIRPORT_ID, f.DEST_AIRPORT_ID
ORDER BY TOTAL_PASSENGERS DESC
limit 10;

## Total Passengers Served in the duration.

SELECT 
    f.YEAR,
    f.MONTH,
    round(SUM(fm.PASSENGERS)/1000000,2) AS TOTAL_PASSENGERS
FROM Flight f
JOIN Flightmetrics fm ON f.FLIGHT_ID = fm.FLIGHT_ID
GROUP BY f.YEAR, f.MONTH
ORDER BY f.YEAR, f.MONTH;

# Passengers per city

# determine average passengers per flight for various routes and airport

use flight_analysis;

# Average passengers per origin city
SELECT
    f.ORIGIN_AIRPORT_ID,
    a.CITY_NAME AS ORIGIN_CITY,
    COUNT(f.FLIGHT_ID) AS TOTAL_FLIGHTS,
    SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS,
    ROUND(AVG(fm.PASSENGERS), 2) AS AVG_PASSENGERS_PER_FLIGHT
FROM Flight f
JOIN Flightmetrics fm ON f.FLIGHT_ID = fm.FLIGHT_ID
JOIN Airport a ON f.ORIGIN_AIRPORT_ID = a.AIRPORT_ID
GROUP BY f.ORIGIN_AIRPORT_ID
ORDER BY AVG_PASSENGERS_PER_FLIGHT DESC
limit 7;

#  Average passengers per Destination city
SELECT
    f.DESI_AIRPORT_ID,
    a.CITY_NAME AS DESI_CITY,
    COUNT(f.FLIGHT_ID) AS TOTAL_FLIGHTS,
    SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS,
    ROUND(AVG(fm.PASSENGERS), 2) AS AVG_PASSENGERS_PER_FLIGHT
FROM Flight f
JOIN Flightmetrics fm ON f.FLIGHT_ID = fm.FLIGHT_ID
JOIN Airport a ON f.DESI_AIRPORT_ID = a.AIRPORT_ID
GROUP BY f.DESI_AIRPORT_ID
ORDER BY AVG_PASSENGERS_PER_FLIGHT DESC
limit 7;

# Bussiness Flight Routes

### Assess flight frequency and identify high-traffic corridors.
# To assess flight frequency and identify high-traffic corridors, we will:
# 1.Count how often each route (origin → destination) appears — that’s flight frequency.
# 2.Identify routes with the highest number of flights — these are high-traffic corridors.

SELECT 
    f.ORIGIN_AIRPORT_ID,
    f.DEST_AIRPORT_ID,
    a1.CITY_NAME AS ORIGIN_CITY,
    a2.CITY_NAME AS DEST_CITY,
    COUNT(*) AS FLIGHT_COUNT
FROM Flight f
JOIN Airport a1 ON f.ORIGIN_AIRPORT_ID = a1.AIRPORT_ID
JOIN Airport a2 ON f.DEST_AIRPORT_ID = a2.AIRPORT_ID
GROUP BY f.ORIGIN_AIRPORT_ID, f.DEST_AIRPORT_ID
ORDER BY FLIGHT_COUNT DESC
limit 10;

## Los Angels is a part of The top 10 busiest air routes.

select * from flight;
select * from airport;


# Top Performing Airport

### Compare passenger numbers across origin cities to identify top-performing airports.
## Total Passengers and Total No. of Flights

SELECT 
    a.CITY_NAME AS ORIGIN_CITY,
    SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS,
    COUNT(f.FLIGHT_ID) AS TOTAL_FLIGHTS
FROM Flight f
JOIN Flightmetrics fm ON f.FLIGHT_ID = fm.FLIGHT_ID
JOIN Airport a ON f.ORIGIN_AIRPORT_ID = a.AIRPORT_ID
GROUP BY a.CITY_NAME
ORDER BY Total_Flights DESC;

## Destination City

SELECT 
    a.CITY_NAME AS ORIGIN_CITY,
    SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS,
    COUNT(f.FLIGHT_ID) AS TOTAL_FLIGHTS
FROM Flight f
JOIN Flightmetrics fm ON f.FLIGHT_ID = fm.FLIGHT_ID
JOIN Airport a ON f.Dest_AIRPORT_ID = a.AIRPORT_ID
GROUP BY a.CITY_NAME
ORDER BY Total_Flights DESC;

## City Population
## Corelation Between Population and Air Traffic.

select * from city;
select * from all_city_pop;

select substring_index(CityName,',',1) as City_Name,State_ABR,
State_NM, Population
from city c
left join all_city_pop as a
on a.city_name = c.Cityname;

update city
set CityName = SUBSTRING_INDEX(cityname,',',1);

SET SQL_Safe_Updates = 0;

select * from city;

create table City_New
(select City_id,substring_index(CityName,',',1) as City_Name,State_ABR,
State_NM, Population
from city c
left join all_city_pop as a
on a.city_name = c.Cityname);

select * from city_new;



use flight_analysis;

select * from airport;
Alter table city_new rename city;
select * from city;

update airport
set City_Name = SUBSTRING_INDEX(city_name,',',1);

SET SQL_Safe_Updates = 0;

### Analyse the relation between city population and airport traffic. 

## Cities as Origin
 
SELECT 
    c.CITY_NAME,
    c.POPULATION,
    SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS
FROM City c
JOIN Airport a ON a.CITY_NAME = c.CITY_NAME
JOIN Flight f ON f.ORIGIN_AIRPORT_ID = a.AIRPORT_ID
JOIN Flightmetrics fm ON f.FLIGHT_ID = fm.FLIGHT_ID
GROUP BY c.CITY_NAME, c.POPULATION
ORDER BY TOTAL_PASSENGERS DESC;

SELECT 
    c.CITY_NAME,
    c.POPULATION,
    SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS,
    round(SUM(fm.PASSENGERS)/c.Population,2) as Pass_Pop_Ratio  
FROM City c
JOIN Airport a ON a.CITY_NAME = c.CITY_NAME
JOIN Flight f ON f.ORIGIN_AIRPORT_ID = a.AIRPORT_ID
JOIN Flightmetrics fm ON f.FLIGHT_ID = fm.FLIGHT_ID
GROUP BY c.CITY_NAME, c.POPULATION
ORDER BY Pass_Pop_ratio DESC;


## Cities as Destination
 
SELECT 
    c.CITY_NAME,
    c.POPULATION,
    SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS
FROM City c
JOIN Airport a ON a.CITY_NAME = c.CITY_NAME
JOIN Flight f ON f.Dest_AIRPORT_ID = a.AIRPORT_ID
JOIN Flightmetrics fm ON f.FLIGHT_ID = fm.FLIGHT_ID
GROUP BY c.CITY_NAME, c.POPULATION
ORDER BY TOTAL_PASSENGERS DESC;

SELECT 
    c.CITY_NAME,
    c.POPULATION,
    SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS,
    count(f.flight_id) as Total_Flights,
    round(SUM(fm.PASSENGERS)/c.Population,2) as Pass_Pop_Ratio  
FROM City c
JOIN Airport a ON a.CITY_NAME = c.CITY_NAME
JOIN Flight f ON f.Dest_AIRPORT_ID = a.AIRPORT_ID
JOIN Flightmetrics fm ON f.FLIGHT_ID = fm.FLIGHT_ID
GROUP BY c.CITY_NAME, c.POPULATION
ORDER BY Pass_Pop_Ratio DESC;

# Creating Views

use flight_analysis;

create view Pass_Pop_Des as
SELECT
	c.CITY_NAME,
    c.POPULATION,
    SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS,
    count(f.flight_id) as Total_Flights,
    round(SUM(fm.PASSENGERS)/c.Population,2) as Pass_Pop_Ratio
FROM City c
JOIN Airport a ON a.CITY_NAME = c.CITY_NAME
JOIN Flight f ON f.Dest_AIRPORT_ID = a.AIRPORT_ID
JOIN Flightmetrics fm ON f.FLIGHT_ID = fm.FLIGHT_ID
GROUP BY c.CITY_NAME, c.POPULATION
ORDER BY Pass_Pop_Ratio DESC;

select * from Pass_Pop_Des;

create view Pass_Pop_Ori as
SELECT
	c.CITY_NAME,
    c.POPULATION,
    SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS,
    count(f.flight_id) as Total_Flights,
    round(SUM(fm.PASSENGERS)/c.Population,2) as Pass_Pop_Ratio
FROM City c
JOIN Airport a ON a.CITY_NAME = c.CITY_NAME
JOIN Flight f ON f.ORIGIN_AIRPORT_ID = a.AIRPORT_ID
JOIN Flightmetrics fm ON f.FLIGHT_ID = fm.FLIGHT_ID
GROUP BY c.CITY_NAME, c.POPULATION
ORDER BY Pass_Pop_Ratio DESC;

select * from Pass_Pop_Ori;

# Stored Procedures

Delimiter //
create procedure traffic()
Begin
SELECT 
    a.CITY_NAME AS ORIGIN_CITY,
    SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS,
    COUNT(f.FLIGHT_ID) AS TOTAL_FLIGHTS
FROM Flight f
JOIN Flightmetrics fm ON f.FLIGHT_ID = fm.FLIGHT_ID
JOIN Airport a ON f.Dest_AIRPORT_ID = a.AIRPORT_ID
GROUP BY a.CITY_NAME
ORDER BY Total_Flights DESC;
END //

Delimiter //
create procedure State_level_traffic(IN State varchar(30))
Begin
SELECT 
    a.CITY_NAME AS ORIGIN_CITY,
    SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS,
    COUNT(f.FLIGHT_ID) AS TOTAL_FLIGHTS
FROM Flight f
JOIN Flightmetrics fm ON f.FLIGHT_ID = fm.FLIGHT_ID
JOIN Airport a ON f.Dest_AIRPORT_ID = a.AIRPORT_ID
where a.state_nm = State
GROUP BY a.CITY_NAME
ORDER BY Total_Flights DESC;
END //

Delimiter ;

call State_level_traffic("Alaska");

select * from airport;

Delimiter //
create procedure sp_top_routes_by_passenger(IN threshold INT)
Begin
	SELECT 
		a1.CITY_NAME AS ORIGIN_CITY,
		a2.CITY_NAME AS DESI_CITY,
        SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS
    FROM Flight f
	JOIN Flightmetrics fm ON f.FLIGHT_ID = fm.FLIGHT_ID
    JOIN Airport a1 ON f.ORIGIN_AIRPORT_ID = a1.AIRPORT_ID
    JOIN Airport a2 ON f.DEST_AIRPORT_ID = a2.AIRPORT_ID
    GROUP BY a1.CITY_NAME, a2.CITY_NAME
    HAVING TOTAL_PASSENGERS > threshold
    ORDER BY Total_Flights DESC;
END //

Delimiter ;

select * from airport;

call sp_top_routes_by_passenger(10000);


    