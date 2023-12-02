-- Looking at total cases vs total deaths
-- shows likelihood  of dying if you contract in your country

select location,date, total_cases,total_deaths,((TRY_CONVERT(float, total_deaths))/(TRY_CONVERT(float,total_cases))*100) as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%china%' 
and continent is not null
order by 1,2


-- Looking at Total cases vs Population

select location,date, total_cases,population,((TRY_CONVERT(float, total_cases))/(TRY_CONVERT(float,population))*100) as ConfirmedCases
from PortfolioProject..CovidDeaths
where continent is not null
and location like '%india%'
order by 1,2

-- Looking at countries with highest infection rate

select location,population ,max(total_cases) as HighestInfection,Max((TRY_CONVERT(float, total_cases))/(TRY_CONVERT(float,population))*100) as Infectionrate
from PortfolioProject..CovidDeaths
where continent is not null
and location like '%india%'
group by location,population
order by 4 desc

-- Looking at countries highest number of deaths per population
--select location, max(cast(total_deaths as int)) as TotalDeaths # we can use cast also to convert from one data type to another
select location, max(TRY_CONVERT(float,total_deaths)) as TotalDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeaths desc

-- lets break it down by continent 
select location, max(TRY_CONVERT(float,total_deaths)) as TotalDeaths
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeaths desc



--Showing the continents with highest death count

select continent, max(TRY_CONVERT(float,total_deaths)) as TotalDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeaths desc


-- GLobal Numbers

select sum(new_cases),sum(new_deaths),
(sum(TRY_CONVERT(float,new_deaths))/( sum(TRY_CONVERT(float,nullif( new_cases,0)))))*100 as GlobalDeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

select date,sum(new_cases),sum(new_deaths),
(sum(TRY_CONVERT(float,new_deaths))/( sum(TRY_CONVERT(float,nullif( new_cases,0)))))*100 as GlobalDeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


-- Looking at total population vs Vaccination
--USING CTE

with POPvsVAC(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select Deaths.continent,Deaths.location,population,Deaths.date,vaccine.new_vaccinations,
sum(try_convert(float, vaccine.new_vaccinations)) 
over (partition by deaths.location order by deaths.location,deaths.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Deaths
join PortfolioProject..CovidVaccinations vaccine
on Deaths.location = vaccine.location
and Deaths.date = vaccine.date
where Deaths.continent is not null
--order by 2,4
)
select *,(TRY_CONVERT(float,RollingPeopleVaccinated/TRY_CONVERT(float,population)))*100 from POPvsVAC


-- Using Temp Table