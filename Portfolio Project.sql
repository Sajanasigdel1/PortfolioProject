--Dataset collected on 07/08/2023

Select *
	from ProjectPortfolio..CovidDeaths 
	Where continent is not null
order by 3,4


--Selecting Data that we are going to use

Select Location, date, total_cases, new_cases,total_deaths, population
	from ProjectPortfolio..CovidDeaths
	Where continent is not null
order by 1,2


--Convert the data type to float
ALTER TABLE  CovidDeaths ALTER COLUMN total_cases FLOAT
ALTER TABLE CovidDeaths ALTER COLUMN total_deaths FLOAT


--Total Cases Vs Total Deaths
--Shows you the likelihood of dying of COVID in your Country

Select Location, date, total_cases, total_deaths,(total_deaths) / ( total_cases) * 100 as DeathPercentage
	from ProjectPortfolio..CovidDeaths
	Where location like '%states%' and continent is not null
order by 1,2


--Total Cases vs Population
--Shows percentage of people who got COVID

Select Location, date, population, total_cases, (total_cases) / ( population) * 100 as PercentageOfPeopleGettingCovid
	from ProjectPortfolio..CovidDeaths
	Where continent is not null
order by 1,2


-- Countries with Highest Infection Rate compared to population 

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases) / ( population))* 100 as HighPercentageOfPeopleGettingCovid
	from ProjectPortfolio..CovidDeaths
	Where continent is not null
	Group by population, location
order by HighPercentageOfPeopleGettingCovid desc


--Break things down by Continent
--Contient with the highest death count per population 

Select continent, MAX(cast(total_deaths as bigint))as TotalDeathCount
	from ProjectPortfolio..CovidDeaths
	Where continent is not null
	Group by continent
order by TotalDeathCount desc

--Break things down by location and continent being null
Select location, MAX(cast(total_deaths as bigint))as TotalDeathCount
	from ProjectPortfolio..CovidDeaths
	Where continent is null
	Group by location
order by TotalDeathCount desc


--Global Numbers

Select date, SUM(new_cases) as TotalNewCase, SUM(new_deaths) as TotalNewDeaths, SUM(new_deaths)/ SUM(nullif( new_cases, 0)) * 100 as DeathperNewCases --total_cases, total_deaths,(total_deaths) / ( total_cases) * 100 as DeathPercentage
	from ProjectPortfolio..CovidDeaths
--Where location like '%states%'
	where continent is null
--where new_cases is not null and new_deaths is not null
	group by date
order by 1,2


--Total new cases and total new Deaths all together

Select SUM(new_cases) as TotalNewCase, SUM(new_deaths) as TotalNewDeaths, SUM(new_deaths)/ SUM(nullif( new_cases, 0)) * 100 as DeathperNewCases --total_cases, total_deaths,(total_deaths) / ( total_cases) * 100 as DeathPercentage
	from ProjectPortfolio..CovidDeaths
	where continent is null
	group by date
order by 1,2


--COVID VACCINATION

Select *
	from ProjectPortfolio..CovidDeaths as DE
	join ProjectPortfolio..CovidVaccinations as VA
	on de.location = VA.location 
	and de.date = VA.date



 --Total population vs vaccination 
 --Total rollingVaccinated partitioned by Location

 Select de.continent, de.location, de.date, de.population, va.new_vaccinations, 
	SUM(convert(bigint, new_vaccinations)) over 
	 (Partition by de.location order by de.location, de.date) RollingPeopleVaccinated, 
	 --(RollingPeopleVaccinated / population) * 100
from ProjectPortfolio..CovidDeaths as de
	 join ProjectPortfolio..CovidVaccinations as va
	 on de.location = va.location 
	and de.date = va.date
	where de.continent is not null --and de.location like '%albani%'
 order by 2,3


 --USE CTE
 with PopvsVac (continent, location, date, population, RollingPeopleVaccinated, new_vaccinations)
 as 
 (
 Select de.continent, de.location, de.date, de.population, va.new_vaccinations, 
	SUM(convert(bigint, new_vaccinations)) over 
	 (Partition by de.location order by de.location, de.date) RollingPeopleVaccinated
	 --(RollingPeopleVaccinated / population) * 100
from ProjectPortfolio..CovidDeaths as de
	 join ProjectPortfolio..CovidVaccinations as va
	 on de.location = va.location 
	and de.date = va.date
	where de.continent is not null --and de.location like '%albani%'
 --order by 2,3
 )
 Select *, (RollingPeopleVaccinated / population) * 100 as RollingPercentage
 from PopvsVac


 --TEMP Table
Drop table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated (
	continent nvarchar(255), 
	Location nvarchar(255),
	Date datetime, 
	Population numeric,
	New_Vaccinations numeric, 
	RollingPeopleVaccinated numeric 
	)

 Insert into #PercentPopulationVaccinated
 Select de.continent, de.location, de.date, de.population, va.new_vaccinations, 
	SUM(convert(bigint, new_vaccinations)) over 
	 (Partition by de.location order by de.location, de.date) RollingPeopleVaccinated
	 --(RollingPeopleVaccinated / population) * 100
from ProjectPortfolio..CovidDeaths as de
	 join ProjectPortfolio..CovidVaccinations as va
	 on de.location = va.location 
	and de.date = va.date
	where de.continent is not null --and de.location like '%albani%'
 --order by 2,3
 
 Select *, (RollingPeopleVaccinated / population) * 100 as RollingPercentage
 from #PercentPopulationVaccinated



 -- Create View to store data for visulization
 Create View PercentPopulationVaccinated as
	 Select de.continent, de.location, de.date, de.population, va.new_vaccinations, 
		SUM(convert(bigint, new_vaccinations)) over 
		 (Partition by de.location order by de.location, de.date) RollingPeopleVaccinated
	from ProjectPortfolio..CovidDeaths as de
	 join ProjectPortfolio..CovidVaccinations as va
	 on de.location = va.location 
	and de.date = va.date
	where de.continent is not null 

	Select *
	from PercentPopulationVaccinated