select *
from oluwatomia..CovidDeaths$

select *
from oluwatomia..CovidVaccinations$

select *
from oluwatomia..CovidDeaths$
where continent is not null
order by 3,4

--Query of covid deaths table
select location, date, population, total_cases, new_cases, total_deaths
from oluwatomia..CovidDeaths$
order by 1,2


--table 1
select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from oluwatomia..CovidDeaths$
--where location = 'Nigeria'
where continent is not null
order by 1,2

---- case incidence i.e total cases vs population
--select location, population, total_cases, new_cases, (total_cases/population)*100 as CasePercentage
--from oluwatomia..CovidDeaths$
----where location = 'Nigeria'
--order by 1,2

---- total cases by location and continent
--select location, max(total_cases) as ContinentTotalCases
--from oluwatomia..CovidDeaths$
--where location = 'Nigeria'
----and continent is not null
--group by location
----group by continent
--order by 1,2

-- date counts
-- (continent)

--select continent, max(cast(total_deaths as int)) as ContinentDeathCount
--from oluwatomia..CovidDeaths$
--where continent is not null
----and location = 'Nigeria'
--group by continent
--order by ContinentDeathCount desc

--(table 2) death count
select location, max(cast(total_deaths as int)) as TotalDeathCount
from oluwatomia..CovidDeaths$
where continent is null
and location not in('world', 'European Union', 'international')
group by location
order by TotalDeathCount desc


-- infection rate by country
select location, date, population, total_cases, (total_cases/population)*100 as infectionpercentage 
from tomiwa..CovidDeaths$
--where location = 'Nigeria'
order by 1,2

select continent, date, population, total_cases, (total_cases/population)*100 as infectionpercentage 
from tomiwa..CovidDeaths$
--where location = 'Nigeria'
where continent is not null
order by 1,2

--table 3
select location, population, max(total_cases) as highestinfectioncount, max(total_cases/population)*100 as percentageinfection 
from tomiwa..CovidDeaths$
--where location = 'Nigeria'
--where continent is not null
group by location, population
order by percentageinfection desc

--table 4
select location, population, date, max(total_cases) as highestinfectioncount, max(total_cases/population)*100 as percentageinfection 
from tomiwa..CovidDeaths$
--where location = 'Nigeria'
--where continent is not null
group by location, population, date
order by percentageinfection desc


--vaccination
select *
from oluwatomia..CovidVaccinations$
order by 3,4

-- join of table covid daths and covid vaccination
select *
from oluwatomia..CovidDeaths$ death
join oluwatomia..CovidVaccinations$ vacc
	on death.location = vacc.location
	and death.date = vacc.date
order by 3,4

-- population and vaccination
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
from oluwatomia..CovidDeaths$ death
join oluwatomia..CovidVaccinations$ vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
order by 2,3

--daily vaccination summation
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(cast(vacc.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) as VaccSummation
from oluwatomia..CovidDeaths$ death
join oluwatomia..CovidVaccinations$ vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
order by 2,3

--temp table

create table PercentagePopulationVaccine
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Populaton numeric,
New_vaccinations Numeric,
VacSummation numeric
)

insert into PercentagePopulationVaccine
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, sum(convert(int,vacc.new_vaccinations)) over (partition by death.location order by death.location
, death.date) as VacSummation
from oluwatomia..CovidDeaths$ death
join tomiwa..CovidVaccinations$ vacc
on death.location = vacc.location
and death.date = vacc.date
where death.continent is not null
--order by 2,3

select *, (VacSummation/Populaton)*100 as percentagevacc
from PercentagePopulationVaccine

--create view for visuazation
create view PercentagePopulationVaccinate as
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, sum(convert(int,vacc.new_vaccinations)) over (partition by death.location order by death.location
, death.date) as VacSummation
from oluwatomia..CovidDeaths$ death
join tomiwa..CovidVaccinations$ vacc
on death.location = vacc.location
and death.date = vacc.date
where death.continent is not null
--order by 2,3

select * from PercentagePopulationVaccinate