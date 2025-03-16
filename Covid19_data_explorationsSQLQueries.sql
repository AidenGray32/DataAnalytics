--Table Data conformation query
--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--SELECT * FROM PortfolioProject..CovidDeaths
--ORDER BY 3, 4

--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

-- Select the DATA that we will be using
Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2
--						--Data Exploration--

-- Observing the Total Cases in relation to the Total number of deaths
-- Showing how likely it is for an individual to die if they contract the Corona Virus in there respective countries
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%jamaica%'
ORDER BY 1, 2


-- Observing the total cases relative to the population
-- by displaying what percentage of the population has been infected at a given time
SELECT location, date, total_cases, population, (total_cases/population) * 100 as Population_Infection_percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%jamaica%'
ORDER BY 1, 2

-- Observing countries with the highest infection rate in relation to their population
SELECT location, population, MAX(total_cases) as Infection_count, MAX((total_cases/population)) * 100 as Population_Infection_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%jamaica%'
GROUP BY location, population
ORDER BY Population_Infection_percentage desc

-- Observing a country's highest death count in relation to others
SELECT location, MAX(cast(total_cases as int)) as Total_Deaths_Count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location like '%jamaica%'
GROUP BY location
ORDER BY Total_Deaths_Count desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT location, MAX(cast(total_cases as int)) as Total_Deaths_Count
FROM PortfolioProject..CovidDeaths
WHERE continent is null
AND location not like '%international%' AND location not like '%World%' AND location not like '%Union%'
--WHERE location like '%jamaica%'
GROUP BY location
ORDER BY Total_Deaths_Count desc

-- Global Numbers
Select  SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--Group by date
Order by 1, 2

--Obderving total Vaccinations in relation to the respective population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Cumulative_vaccination_count
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
AND dea.location like '%albania%'
order by 2, 3

-- Using CTE

With PopulationVaccination (Continent, Location, Date, Population, new_vaccinations, Cumulative_vaccination_count)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Cumulative_vaccination_count
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
AND dea.location like '%albania%'
--order by 2, 3
)

SELECT *, (Cumulative_vaccination_count/Population)*100 as Percnetage FROM PopulationVaccination

-- The use of TEMP TABLE
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
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--AND dea.location like '%albania%'
--order by 2, 3

SELECT *, (Cumulative_vaccination_count/Population)*100 as Percnetage FROM #Cumulative_Vaccination_table


-- Creating Cummulative Vaccination Count view for Tableau Visualization

Create view Cumulative_Vaccination_count as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Cumulative_vaccination_count
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--AND dea.location like '%albania%'
--order by 2, 3

Select * From Cumulative_Vaccination_count
