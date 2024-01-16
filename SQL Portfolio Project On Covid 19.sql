select * from CovidDeaths
where continent is Not NULL
order by 3,4

select * from CovidVaccination
order by 3,4

--- Data that we will be using---
select location, date, total_cases, new_cases, total_deaths,
population from CovidDeaths
order by 1,2

---Total cases vs total deaths---
--liklihood of death if someone got contacted to covid---
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from CovidDeaths
where location like '%states'
order by 1,2

---total cases Vs Population---
--Percentage of population got covid---
select location, date, Population, total_cases,   (total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths
---where location like '%states'
order by 1,2

---Countries with higest infection rate compared to population---
select location, Population, max(total_cases) as HighestInfectionCount, 
Max((total_cases/population))*100 as  PercentagePopulationInfected
from CovidDeaths
Group By location, Population
---where location like '%states'
order by  PercentagePopulationInfected desc

--countries with highest death count per Population---
select location, MAX(Cast(total_deaths as int)) as totalDeathCount
from CovidDeaths
where continent is Not NULL
Group By location
---where location like '%states'
order by  totalDeathCount desc

---Check through continent---
select continent, MAX(Cast(total_deaths as int)) as totalDeathCount
from CovidDeaths
where continent is not NULL
Group By continent
---where location like '%states'
order by  totalDeathCount desc

--continents with highest death count per population---
select continent, MAX(Cast(total_deaths as int)) as totalDeathCount
from CovidDeaths
where continent is Not NULL
Group By continent
---where location like '%states'
order by  totalDeathCount desc

---Global Numbers---
select  date, SUM(new_cases) as TotalCases,  SUM(CAST(new_deaths as int)) as TotalDeaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is Not NULL
Group By date
order by 1,2

---Looking at Total Population Vs Vaccination---

select dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations
From CovidDeaths Dea Inner Join CovidVaccination Vac
ON dea.location=Vac.location And Dea.date=Vac.date
where Dea.continent is Not null
Order by 2,3

---Looking at Total Population Vs Vaccination---
select dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations, 
SUM(CAST(Vac.new_vaccinations as int)) OVER(Partition BY dea.location order by dea.location, dea.date)
From CovidDeaths Dea Inner Join CovidVaccination Vac
ON dea.location=Vac.location And Dea.date=Vac.date
where Dea.continent is Not null
Order by 2,3

---Looking at Total Population Vs Vaccination---
select dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations, 
SUM(CAST(Vac.new_vaccinations as int)) OVER(Partition BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
---,(RollingPeopleVaccinated/population)*100
From CovidDeaths Dea Inner Join CovidVaccination Vac
ON dea.location=Vac.location And Dea.date=Vac.date
where Dea.continent is Not null
Order by 2,3

---use CTE---
With POPvsVac(Continent,location,date, population,new_vaccinations, RollingPeopleVaccinated )
as
(
select dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations, 
SUM(CAST(Vac.new_vaccinations as int)) OVER(Partition BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
---,(RollingPeopleVaccinated/population)*100
From CovidDeaths Dea Inner Join CovidVaccination Vac
ON dea.location=Vac.location And Dea.date=Vac.date
where Dea.continent is Not null
---Order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
from POPvsVac

---Temp Table--
Drop Table if Exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(Continent nvarchar(50),
Location nvarchar(50),
Date Datetime,
Population Numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
select dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations, 
SUM(CAST(Vac.new_vaccinations as int)) OVER(Partition BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
---,(RollingPeopleVaccinated/population)*100
From CovidDeaths Dea Inner Join CovidVaccination Vac
ON dea.location=Vac.location And Dea.date=Vac.date
---where Dea.continent is Not null
---Order by 2,3
Select *,(RollingPeopleVaccinated/population)*100
from #PercentagePopulationVaccinated

----Creating View to store data for later Visualization---

Create View PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations, 
SUM(CAST(Vac.new_vaccinations as int)) OVER(Partition BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
---,(RollingPeopleVaccinated/population)*100
From CovidDeaths Dea Inner Join CovidVaccination Vac
ON dea.location=Vac.location And Dea.date=Vac.date
where Dea.continent is Not null

select * from PercentagePopulationVaccinated


