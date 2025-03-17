
-- Covid-19 Data exploration

-- Confirming that the data has been imported correctly
SELECT *
FROM CovidDataSet..CovidDeaths
ORDER BY 1, 2

SELECT *
FROM CovidDataSet..CovidVaccinations
ORDER BY 1, 2



--Exploration of data--

-- 1. Observing the total number of Covid-19 cases in relation to the Total number of deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM CovidDataSet..CovidDeaths
ORDER BY 1, 2



/* 2. Observing the total number of Covid-19 cases in relation to the population
   by calculating what percentage of the population has been infected at a given point in time*/
SELECT location, date, total_cases, population, (total_cases/population) * 100 as Population_Infection_percentage
FROM CovidDataSet..CovidDeaths
ORDER BY 1, 2



-- 3. To calculate and measure population infection of COVID-19

SELECT location, population, MAX(total_cases) as Infection_count, MAX((total_cases/population)) * 100 as Population_Infection_percentage
FROM CovidDataSet..CovidDeaths
WHERE location not in ('World', 'European Union', 'International')
GROUP BY location, population
ORDER BY Population_Infection_percentage desc

SELECT location, population, date, MAX(total_cases) as Infection_count, MAX((total_cases/population)) * 100 as Population_Infection_percentage
FROM CovidDataSet..CovidDeaths
WHERE location not in ('World', 'European Union', 'International')
GROUP BY location, population, date
ORDER BY Population_Infection_percentage desc



-- 4. Comparing COVID-19 mortality volume across countries.

SELECT location, MAX(cast(total_cases as int)) as Total_Death_Count
FROM CovidDataSet..CovidDeaths
WHERE continent is not null
AND location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY Total_Death_Count desc


-- BREAKING THINGS DOWN BY CONTINENT

SELECT location, MAX(cast(total_cases as int)) as Total_Death_Count
FROM CovidDataSet..CovidDeaths
WHERE continent is null
AND location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY Total_Death_Count desc


-- Global Numbers

SELECT  SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Death_percentage
FROM CovidDataSet..CovidDeaths
WHERE continent is not null
--Group by date
ORDER BY 1, 2



/* 5. Observing total Vaccinations in relation to the respective population
--	  Cumulative Count*/

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Cumulative_vaccination_count
FROM CovidDataSet..CovidDeaths dea
JOIN CovidDataSet..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2, 3



-- Cumulative vaccination count as a percentage using CTE

With PopulationVaccination (Continent, Location, Date, Population, new_vaccinations, Cumulative_vaccination_count)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Cumulative_vaccination_count
FROM CovidDataSet..CovidDeaths dea
JOIN CovidDataSet..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
)
SELECT *, (Cumulative_vaccination_count/Population)*100 as Percnetage FROM PopulationVaccination



-- Generating a vaccnation count temp table

DROP Table if exists #Cumulative_Vaccination_table
Create Table #Cumulative_Vaccination_table
(
	Contnent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	Cumulative_Vaccination_Count numeric
)

INSERT INTO #Cumulative_Vaccination_table
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Cumulative_vaccination_count
FROM CovidDataSet..CovidDeaths dea
JOIN CovidDataSet..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
SELECT *, (Cumulative_vaccination_count/Population)*100 as Percnetage FROM #Cumulative_Vaccination_table



-- Generating a Cummulative Vaccination Count view for Tableau Visualization

Create view Cumulative_Vaccination_count_view as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Cumulative_vaccination_count
FROM CovidDataSet..CovidDeaths dea
JOIN CovidDataSet..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 

--/
Select * From Cumulative_Vaccination_count_view
