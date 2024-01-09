
Select CONVERT(date, date) As Date , Location,population,
 total_cases,total_deaths,new_cases
 From CovidDeaths
 where Location is not Null
	Order by 2

--Covid19 death rate in Nigeria
Select CONVERT(date, date) As Date , Location,population, total_cases,total_deaths,
	Convert(bigint,total_deaths)*1.0/Convert(bigint,total_cases) * 100 DeathPercentage
 From CovidDeaths
 where Location = 'Nigeria'
	Order by 1,2

-- Percentage of covid infection against population
Select CONVERT(date, date) As Date , Location,population, total_cases,
	Convert(bigint,total_cases)*1.0/population * 100 DeathPercentage
 From CovidDeaths
 where Location = 'Nigeria'
	Order by 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE AGAINST POPULATION
Select  Location,population, Max(Convert(bigint,total_cases)) MaxInfection,
	Max(total_cases) / population * 100 InfectionPopPercentage
 From CovidDeaths
 where Location is not Null
	group by location,population
	Order by 4 Desc


--Showing Countries with the Highest Number of Deaths 

Select  Location,population,Sum(new_cases) AS TotalCases, Max(convert(bigint,total_deaths)) MaxDeaths,
Max(convert(bigint,total_deaths)) / population * 100 Deaths_Pop_Percentage, Max(convert(bigint,total_deaths)) / Sum(new_cases) As Deaths_Inf_Percent
 From CovidDeaths
 where Location is not Null
	group by location,population
	Order by 4 Desc


--Showing Continent with the Highest Number of Deaths
Select  location, Population,Max(Convert(bigint,total_deaths)) as Deathcount,
 Max(Convert(bigint,total_deaths)) / Population * 100 Pop_Death_Percent
 From CovidDeaths
 where continent is Null
	group by location, population
	Order by 2 Desc

	--Showing Global Infection Against Total Deaths (2 Options)
	--Ovearall Covid cases that results to fatality worldwide.
Select  Max(Convert(bigint,total_cases)) as Casecount, Max(Convert(bigint,total_deaths)) as Deathcount,
	Max(Convert(bigint,total_deaths)) * 1.0 / Max(Convert(bigint,total_cases)) * 100 As GlobalDeathpercentage
 From CovidDeaths
 where location is not Null
	
	
	Select  Sum(Convert(int,new_cases)) as Casecount, Sum(Convert(int,new_deaths)) as Deathcount,
		Sum(Convert(int,new_deaths)) * 1.0 / Sum(Convert(int,new_cases)) * 100 GlobalDeathpercentage
		 From CovidDeaths
	 where continent is not null

	 --Showing Total Population vs Vaccination (2 options)

Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
 from CovidDeaths dea
	Join CovidVaccinations vac
	On dea.date = vac.date
	And dea.location = vac.location
	--Where dea.continent is not null
	 Order by 2,3

	 

	 Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
	 Sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) CumulativeVac
 from CovidDeaths dea
	Join CovidVaccinations vac
	On dea.date = vac.date
	And dea.location = vac.location
	Where dea.continent is not null
	 Order by 2,3

	  --Using CTE to show the percentage of total Pop. vs C_Vaccination Percentage

With CumVacvsPop
(continent,location,date,population, new_vaccinations,CumulativeVac)
As
(Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
	 Sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) CumulativeVac
 from CovidDeaths dea
	Join CovidVaccinations vac
	On dea.date = vac.date
	And dea.location = vac.location
	Where dea.continent is not null
	)
	Select *,
	(CumulativeVac / population) * 100 C_Vac_percentage
	From CumVacvsPop

	--TempTable

Drop Table If Exists #CumulativeVacvsPop
Create Table #CumulativeVacvsPop
(continent nvarchar(255), location nvarchar(255), date datetime, population bigint,
new_vaccinations bigint, CumulativeVac bigint)

Insert Into #CumulativeVacvsPop
	Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
	 Sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) CumulativeVac
 from CovidDeaths dea
	Join CovidVaccinations vac
	On dea.date = vac.date
	And dea.location = vac.location
	Where dea.continent is not null

Select * 
From #CumulativeVacvsPop 