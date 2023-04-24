
SELECT *
FROM Portfolio_Project..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM Portfolio_Project..CovidVaccinations
--order by 3,4

-- Select data that we are going to be using
select Location, date, total_cases, total_deaths, new_cases, population
from CovidDeaths
where continent is not null
order by 1,2
-- Looking at Total Cases and Total Deaths
-- Show likelihood of dying if you contract covid in your country 
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths
where location like '%Viet%'
order by 1,2

-- Looking at Total Cases and Population 
-- Show percentage of population that got Covid
select Location, date,population ,total_cases ,(total_cases/population)*100 as Percent_Population_Infected
from CovidDeaths
where location like '%Viet%'
order by 1,2


-- Looking at countries with highest infection rate compared to Population 
SELECT location , population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Highest_Percent_Population_Infected
from CovidDeaths
where continent is not null
group by location,population
order by  Highest_Percent_Population_Infected DESC

-- BREAK THINGS DOWN BY CONTINENT

SELECT continent,MAX(total_deaths) as Highest_Deaths_Count
from CovidDeaths
where continent is not null
group by continent
order by Highest_Deaths_Count DESC

-- Showing Countries with Highest Death Count per Population
SELECT location,population,MAX(total_deaths) as Highest_Deaths_Count
from CovidDeaths
where continent is not null
group by location,population
order by Highest_Deaths_Count DESC

-- Showing contintents with the highest death count per population

Select continent,MAX((total_deaths/population))*100 as highest_death_count_per_population
from CovidDeaths
where continent is not null
group by continent 
order by highest_death_count_per_population desc



-- GLOBAL NUMBER

select date, sum(new_cases) as a,SUM(new_deaths) as b
	from CovidDeaths
--where location like '%Viet%' 
	where continent is not null
	group by date
order by 1,2


-- Looking at total Pupolation vs Vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) Over (Partition by dea.location
order by dea.location ,dea.date) as Total_Vaccination_Of_Locations
	From CovidDeaths dea
	join CovidVaccinations vac 
	on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null
	order by 2,3


-- USE CTE
With PopvsVac(continent,Location,date,population,new_vaccinations,Total_Vaccination_Of_Locations) 
AS (
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) Over (Partition by dea.location
order by dea.location ,dea.date) as Total_Vaccination_Of_Locations
	From CovidDeaths dea
	join CovidVaccinations vac 
	on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)
select *,(Total_Vaccination_Of_Locations/population)*100 as VacPerPop
from PopvsVac

-- TEMP TABLE
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
Total_Vaccination_Of_Locations numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) Over (Partition by dea.location
order by dea.location ,dea.date) as Total_Vaccination_Of_Locations
	From CovidDeaths dea
	join CovidVaccinations vac 
	on dea.location = vac.location and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3

select *,(Total_Vaccination_Of_Locations/population)*100 as VacPerPop
from #PercentPopulationVaccinated

-- Create View
Drop view PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) Over (Partition by dea.location
order by dea.location ,dea.date) as Total_Vaccination_Of_Locations
	From CovidDeaths dea
	join CovidVaccinations vac 
	on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	
Select *
From PercentPopulationVaccinated
order by 1 ASC

