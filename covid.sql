-- Select data that we are going to use
--SELECT location, date, total_cases, new_cases, total_deaths, population 
--FROM covid_deaths

--Looking at Total Cases vs Total Deaths
--likelihood of dying if you contract covid
SELECT location, date, total_cases, total_deaths, (total_deaths::decimal/total_cases * 100) AS death_percentage
FROM covid_deaths
WHERE location = 'Mexico'


-- Total Cases vs Population
-- show what porcentage of population got covid
SELECT location, date, total_cases, population, (total_cases::decimal/population * 100) AS percentage_population
FROM covid_deaths
WHERE location = 'Mexico'


--countries with the highest infection rate compared to population
SELECT location, population, MAX (total_cases) AS highest_infection_count, MAX(total_cases::decimal/population * 100) AS percentage_population_infected
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING MAX (total_cases) > 0 AND MAX(total_cases::decimal/population * 100) > 0
ORDER BY percentage_population_infected DESC


--countries with highest death count per population
SELECT location, population, MAX (total_deaths) AS deaths , MAX(total_deaths::decimal/population * 100) AS percentage_population_deceased
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location,population
HAVING MAX (total_deaths) > 0
ORDER BY deaths DESC



-- deaths by continents
SELECT continent,  MAX (total_deaths) AS deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY deaths DESC



--global numbers 
--counting globally the infection and deaths by day
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)::decimal / SUM(new_cases) * 100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--total global numbers
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)::decimal / SUM(new_cases) * 100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- combining north and south america as just one
SELECT 'Americas' AS continent, SUM(total_deaths) AS covid_deaths
FROM covid_deaths
WHERE continent IN ('South America', 'North America');


--TOTAL population vs vaccines
-- using CTE
WITH PoPvsVac (location, date, population, new_vaccinations, total_people_vac )
AS
(
SELECT covid_deaths.location,  covid_deaths.date, covid_deaths.population, covid_vaccinations.new_vaccinations
	,SUM(covid_vaccinations.new_vaccinations) OVER (PARTITION BY covid_deaths.location ORDER BY covid_deaths.location, covid_deaths.date) AS total_people_vac
FROM covid_deaths
JOIN covid_vaccinations
	ON covid_deaths.location = covid_vaccinations.location
	AND covid_vaccinations.date = covid_deaths.date
ORDER BY 1,2
)
SELECT *, (total_people_vac::decimal/population) * 100 AS porcen_countr_vac
FROM PoPvsVac


-- create view to store data for visualization

CREATE VIEW PercentPopulationVaccinated AS
WITH PoPvsVac (location, date, population, new_vaccinations, total_people_vac )
AS
(
SELECT covid_deaths.location,  covid_deaths.date, covid_deaths.population, covid_vaccinations.new_vaccinations
	,SUM(covid_vaccinations.new_vaccinations) OVER (PARTITION BY covid_deaths.location ORDER BY covid_deaths.location, covid_deaths.date) AS total_people_vac
FROM covid_deaths
JOIN covid_vaccinations
	ON covid_deaths.location = covid_vaccinations.location
	AND covid_vaccinations.date = covid_deaths.date
ORDER BY 1,2
)
SELECT *, (total_people_vac::decimal/population) * 100 AS porcen_countr_vac
FROM PoPvsVac