SELECT *
FROM project..CovidDeaths
ORDER by 3,4


--SELECT *
--FROM project..VaccinationInfo
--ORDER BY 3,4



--Now we want the data we want to use in our project

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM project..CovidDeaths
ORDER by 1,2



--Total caes vs total deaths
--Likelyhood of Dying

SELECT location,date,total_cases,total_deaths, (CONVERT(float,total_deaths)/CONVERT(float,total_cases))*100 AS Death_percentage
FROM project..CovidDeaths
WHERE location like '%India%'
ORDER by 1,2




--total_cases vs population
--percentage of population that got covid

SELECT location,date,total_cases,total_deaths, population,(CONVERT(float,total_cases)/CONVERT(float,population))*100 AS percentage_population
FROM project..CovidDeaths
--WHERE location like '%India%'
ORDER by 1,2




--countries with highest infection rates
SELECT location, date, population, MAX(total_cases) AS highest_infection_count, MAX(CONVERT(float,total_cases)*100/CONVERT(float,population)) AS percentage_population
FROM project..CovidDeaths
GROUP BY location, population, date
ORDER by percentage_population DESC




--countries with the highest death count by population
SELECT location,MAX(total_deaths) AS total_death_count
FROM project..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER by 2 DESC




-- breaking things down by continents
SELECT continent,MAX(total_deaths) AS total_death_count
FROM project..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER by 2 DESC




--global numbers

SELECT SUM(CONVERT(float,new_cases)) AS total_cases,SUM(CONVERT(int,new_deaths)) AS total_deaths,(SUM(CONVERT(float,new_deaths))/SUM(CONVERT(float,new_cases)))*100 AS Death_percentage
FROM project..CovidDeaths
--WHERE location like '%India%'

--GROUP BY date
ORDER by 1,2



--Calculating the running sum of the vaccinations

SELECT cd.continent, cd.location, cd.date,cd.population, v.new_vaccinations, SUM(CONVERT(float,v.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rooling_count
FROM CovidDeaths cd
JOIN VaccinationInfo v
ON cd.location=v.location and cd.date=v.date
WHERE cd.continent is not null
ORDER BY 2,3



--population vs vaccination

WITH pvv AS(SELECT cd.continent, cd.location, cd.date,cd.population, v.new_vaccinations, SUM(CONVERT(float,v.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rooling_count
FROM CovidDeaths cd
JOIN VaccinationInfo v
ON cd.location=v.location and cd.date=v.date
WHERE cd.continent is not null)
SELECT *,(pvv.rooling_count/pvv.population)*100 AS pop_vs_vac
FROM pvv




--Creating different views

Create View Continents AS
--now break the things down by continents
SELECT continent,MAX(total_deaths) AS total_death_count
FROM project..CovidDeaths
WHERE continent is not null
GROUP BY continent


Create view populationvsvaccination AS
WITH pvv AS(SELECT cd.continent, cd.location, cd.date,cd.population, v.new_vaccinations, SUM(CONVERT(float,v.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rooling_count
FROM project..CovidDeaths cd
JOIN project..VaccinationInfo v
ON cd.location=v.location and cd.date=v.date
WHERE cd.continent is not null)
SELECT *,(pvv.rooling_count/pvv.population)*100 AS pop_vs_vac
FROM pvv

Create View Globalnumbers AS
SELECT SUM(CONVERT(float,new_cases)) AS total_cases,SUM(CONVERT(int,new_deaths)) AS total_deaths,(SUM(CONVERT(float,new_deaths))/SUM(CONVERT(float,new_cases)))*100 AS Death_percentage
FROM project..CovidDeaths
--WHERE location like '%India%'

--GROUP BY date


Create view highestdeathcount AS 
SELECT location,MAX(total_deaths) AS total_death_count
FROM project..CovidDeaths
WHERE continent is not null
GROUP BY location

CREATE VIEW percentage_effected AS
SELECT location,date,total_cases,total_deaths, population,(CONVERT(float,total_cases)/CONVERT(float,population))*100 AS percentage_population
FROM project..CovidDeaths
--WHERE location like '%India%'
ORDER by 1,2

