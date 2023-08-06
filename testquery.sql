select * from portfiloproject.dbo.CovidDeath
order by 3,4;
---------------------------
select * from portfiloproject.dbo.vaccination
order by 3,4;
--------------------
--change datatype for total_deaths
ALTER TABLE portfiloproject.dbo.CovidDeath
ALTER COLUMN total_deaths decimal
-----------------------------
---change datatype for total_cases_per_million
ALTER TABLE portfiloproject.dbo.CovidDeath
ALTER COLUMN total_cases float;
-----------------
ALTER TABLE portfiloproject.dbo.vaccination
ALTER COLUMN new_vaccinations BIGINT;

----------------------------------------------
--unique value
select distinct(location)
from portfiloproject.dbo.CovidDeath;

--TOTAL CASES VS TOTAL DEATH
select location,date,total_deaths,total_cases,(NULLIF(total_cases,0)/NULLIF(total_deaths,0))*100 as DeathPercentage
from portfiloproject.dbo.CovidDeath
where location like '%STATES%' and continent is not null
order by 1,2;
-----------------------------------
--LOOKIN TOTAL CASES VS POPULATION
select location,date,total_cases,population,(NULLIF(total_cases,0)/NULLIF(POPULATION,0))*100 as PopulationPercentage
from portfiloproject.dbo.CovidDeath
where location like '%STATES%' and continent is not null
order by 1,2;
----------------------
--looking at coutries with highest infection rate compared to poulation
select location,max(total_cases) as HighestInfectionCount,population,max((NULLIF(total_cases,0)/NULLIF(POPULATION,0)))*100 as PercentagePopulationInfected
from portfiloproject.dbo.CovidDeath
--where location like '%STATES%'
where  continent is not null
GROUP BY location, population
order by PercentagePopulationInfected desc;
--------------------------
--looking at countries with highst death count per population
select location, max(total_deaths) as TotalDeathCount
from portfiloproject.dbo.CovidDeath
--where location like '%STATES%'
where continent is not null
GROUP BY location, population
order by TotalDeathCount desc;
--------------------------------------------
select location ,max(cast(total_deaths as int)) as TotalDeathCount
from portfiloproject.dbo.CovidDeath
where continent is not null
group by location
order by TotalDeathCount desc;
---------------------------
--lets break by continent
select continent ,max(cast(total_deaths as int)) as TotalDeathCount
from portfiloproject.dbo.CovidDeath
where continent is not null
group by continent
order by TotalDeathCount desc;

-------------------------------------
--showing continent with highest death count
select sum(new_cases) as TotalCases,sum(cast(NEW_DEATHS AS int ))as TotalDeaths,SUM(new_deaths)/SUM(NEW_CASES)*100 as DeathPercentage
from portfiloproject.dbo.CovidDeath
where continent is not null
group by continent
order by 1,2;
-----------------
--looking total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
       sum(NULLIF(VAC.new_vaccinations,0))OVER (partition by dea.location order by dea.location ,dea.date) AS RollingPeopleVaccination
from portfiloproject.dbo.CovidDeath dea
join  portfiloproject.dbo.vaccination vac
     on dea.location =vac.location
    and dea.date=vac.date
where dea.continent is not null
order by 2,3;
-----------------------
WITH C (continent,location,DATE,population,new_vaccinations,RollingPeopleVaccination) 
AS (
           select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
           sum(NULLIF(VAC.new_vaccinations,0))OVER (partition by dea.location order by dea.location ,dea.date) AS RollingPeopleVaccination
           from portfiloproject.dbo.CovidDeath dea
           join  portfiloproject.dbo.vaccination vac
           on dea.location =vac.location
           and dea.date=vac.date
           where dea.continent is not null
           --order by 2,3
	)
SELECT *,(RollingPeopleVaccination/population)*100
from c;
---------------------------
Create view percentagepopulationvacinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
           sum(NULLIF(VAC.new_vaccinations,0))OVER (partition by dea.location order by dea.location ,dea.date) AS RollingPeopleVaccination
           from portfiloproject.dbo.CovidDeath dea
           join  portfiloproject.dbo.vaccination vac
           on dea.location =vac.location
           and dea.date=vac.date
           where dea.continent is not null
           --order by 2,3
select * from percentagepopulationvacinated;
