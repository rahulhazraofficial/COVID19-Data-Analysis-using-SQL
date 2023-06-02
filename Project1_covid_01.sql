/*
Covid 19 Data Exploration

Skills used : Joins, CTE's, Temp Tables, Windows Function, Aggregate Functions, Creating Views, Converting Data Types

*/




Select *
From Project1..Deaths
where continent is not null
Order By 3,4




-- Some Columns have data type nvarchar(255) but for the sake of calculation changing those to different data types like float and int

alter table project1..deaths alter column total_cases_per_million float
go
alter table project1..deaths alter column new_cases_per_million float
go
alter table project1..deaths alter column total_deaths_per_million float
go
alter table project1..deaths alter column icu_patients int
go
alter table project1..deaths alter column hosp_patients int
go
alter table project1..deaths alter column hosp_patients_per_million float
go





-- data which we will going to work with

select location, date, total_cases, new_cases, total_deaths, population
from Project1..Deaths
where continent is not null
order by 1,2




-- death rate if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
from Project1..Deaths
where location like	'%India%'
and continent is not null
order by 5 desc




-- shows how many people got covid out of total population

select location, date, population, total_cases, (total_cases/population)*100 as CaseRate
from Project1..Deaths
where location like	'%India%'
and continent is not null
order by 5 desc




-- countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectionRatePerPopulation
from Project1..Deaths
where continent is not null
group by location, population
order by 4 desc




-- countries with highest death count per population

select location, max(cast(total_deaths as float)) as TotalDeathCount, max((total_deaths/total_cases))*100 as DeathRatePerCases
from Project1..Deaths
where continent is not null
group by location
order by 2 desc




-- continent with highest death count

select continent, max(total_deaths) as TotalDeathCount
from Project1..Deaths
where continent is not null
group by continent
order by 2 desc




-- global numbers

select  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as NewDeathRateperNewCases --,date
from Project1..Deaths
-- where location like	'%India%'
where continent is not null
-- group by date
order by 1,2




-- TOTAL POPULATION VS VACCINATIONS
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.date) as RollingPeopleVaccinated
from Project1..Deaths d
JOIN Project1..Vacc v
	On d.location = v.location and d.date = v.date
where d.continent is not null
--	  and d.location like '%India%' 
order by 2,3




-- Using CTE to Calculate Partition By in previous query

With PopuVsVacc (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.date) as RollingPeopleVaccinated
from Project1..Deaths d
JOIN Project1..Vacc v
	On d.location = v.location and d.date = v.date
where d.continent is not null
--	  and d.location like '%India%' 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercentage
From PopuVsVacc




--Using TEMP Table to calculate on Partition By in previous query

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations bigint,
RollingPeopleVaccinated numeric,
)


Insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.date) as RollingPeopleVaccinated
from Project1..Deaths d
JOIN Project1..Vacc v
	On d.location = v.location and d.date = v.date
--		where d.continent is not null
--		and d.location like '%India%' 
--		order by 2,3


Select *, (RollingPeopleVaccinated/population)*100 as PercentageofRollingVaccinated
From #PercentPopulationVaccinated




-- Creating View to store data visualisations

Create View PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.date) as RollingPeopleVaccinated
from Project1..Deaths d
JOIN Project1..Vacc v
	On d.location = v.location and d.date = v.date
where d.continent is not null
