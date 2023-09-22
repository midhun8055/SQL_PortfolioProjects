use PORTFOLIOPROJECT_1

select * from coviddeaths
select * from covidvaccination

--Found some false entries in the table from columns location, cleaning it;

delete from coviddeaths where location like '%income%'

--selecting the data relevant to workout

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 2 desc

--changing the datatype of columns for the future calculations

alter table coviddeaths
alter column total_cases float 
alter table coviddeaths
alter column total_deaths float 

-- looking at total cases vs total deaths
-- shows the likelihood of dying if you contract covid in India

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
from coviddeaths
where location like 'india' and total_cases is not null
order by 2

--looking at total cases vs the population in India

select location, date, population, total_cases, (total_cases/population)*100 as infection_percent
from coviddeaths
where location like 'india' and total_cases is not null 
order by 2

--looking at countries with highest infection rate compared to the population

select location, population, max(total_cases) as Highest_count, max((total_cases/population))*100 as infectionpercent_highest
from coviddeaths
where total_cases is not null and continent is not null
group by population, location
order by 4 desc

--showing countries with highest covid death count per population

select location, max(total_deaths) as highest_deathcount
from coviddeaths
where total_deaths is not null and continent is not null
group by location
order by 2 desc

--by continent

select location, max(total_deaths) as highest_deathcount
from coviddeaths
where continent is null and location not like '%union%' and location <> 'world'
group by location
order by 2 desc

-- Global numbers per date

select date, sum(total_cases) as cases, sum(total_deaths) as deaths, sum(total_deaths)/sum(total_cases)*100 as death_percent
from coviddeaths
where total_cases is not null
group by date
order by 1

-- Total global statistics

select sum(total_cases) as cases, sum(total_deaths) as deaths, sum(total_deaths)/sum(total_cases)*100 as death_percent
from coviddeaths
where total_cases is not null

-- looking at total population vs vaccination (with a rolling count of vaccination per date)


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rolling_count
from coviddeaths dea join covidvaccination vac
on dea.location = vac.location and dea.date = vac.date
where vac.new_vaccinations is not null and dea.continent is not null
order by 2,3

-- using a CTE for extraction of the percent measure of vaccination against population

with popvsvac (Continent, location, date, population, new_vaccinations, Rolling_count)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rolling_count
from coviddeaths dea join covidvaccination vac
on dea.location = vac.location and dea.date = vac.date
where vac.new_vaccinations is not null and dea.continent is not null
)
select location, population, (max(Rolling_count)/population)*100 as vaccinated_percent
from popvsvac
group by location, population
order by 1

-- inserting the data into a temp. table

drop table if exists #vacc_stat
create table #vacc_stat
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_count numeric
)
insert into #vacc_stat 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rolling_count
from coviddeaths dea join covidvaccination vac
on dea.location = vac.location and dea.date = vac.date
where vac.new_vaccinations is not null and dea.continent is not null

select location, population, (max(Rolling_count)/population)*100 as vaccinated_percent 
from #vacc_stat
group by location,population
order by location


-- CREATING VIEWS FOR LATER VISUALISATION

-- Creating view on global numbers

create view glob_stat as 
select date, sum(total_cases) as cases, sum(total_deaths) as deaths, sum(total_deaths)/sum(total_cases)*100 as death_percent
from coviddeaths
where total_cases is not null
group by date


-- Creating views on total vaccinated statistics

create view total_vaccination as
with popvsvac (Continent, location, date, population, new_vaccinations, Rolling_count)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rolling_count
from coviddeaths dea join covidvaccination vac
on dea.location = vac.location and dea.date = vac.date
where vac.new_vaccinations is not null and dea.continent is not null
)
select location, population, (max(Rolling_count)/population)*100 as vaccinated_percent
from popvsvac
group by location, population
--order by 1















 



