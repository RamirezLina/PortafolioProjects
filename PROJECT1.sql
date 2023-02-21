SELECT *
FROM PortafolioProject..CovidVac
ORDER BY 3,4

SELECT *
FROM PortafolioProject..CovidDeaths
ORDER BY 3,4

-- DATA EXPLORATION  

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortafolioProject..CovidDeaths
ORDER BY 1,2

 SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PORCENTAJE
FROM PortafolioProject..CovidDeaths
ORDER BY 1,2

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PORCENTAJE
FROM PortafolioProject..CovidDeaths
WHERE Location LIKE 'COLOMBIA%'
ORDER BY 1,2

-- IDENTIFICANDO EL NUMERO MAXIMO DE CASOS Y MUERTES POR COVID EN UN DIA EN COLOMBIA

SELECT MAX(cast(TOTAL_CASES as int)) AS XCASES, MAX(cast(TOTAL_DEATHS as int))AS XDEATHS
FROM PortafolioProject..CovidDeaths
WHERE Location LIKE 'COLOMBIA%'

SELECT MAX(CAST(TOTAL_DEATHS AS int)) 
FROM PortafolioProject..CovidDeaths
WHERE Location LIKE 'COLOMBIA%'

-- IDENTIFICANDO LOS DÍAS DE MAYOR TASA DE MORTALIDAD POR COVID EN COLOMBIA	

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PORCENTAJE
FROM PortafolioProject..CovidDeaths
WHERE Location LIKE 'COLOMBIA%'
ORDER BY (PORCENTAJE) DESC, Date 

-- IDENTIFICANDO LOS DÍAS DE MAYOR TASA DE INFECCIÓN POR COVID EN COLOMBIA

SELECT Location, Date, total_cases, Population, (total_cases/population)*100 AS PORCENTAJE
FROM PortafolioProject..CovidDeaths
WHERE Location LIKE 'COLOMBIA%' AND (total_cases/population)*100 > 0.1
ORDER BY PORCENTAJE DESC

-- IDENTIFICANDO LA TASA DE INFECCION PARA CADA PAIS EN CADA FECHA
SELECT Location, Date, total_cases, Population, (total_cases/population)*100 AS PORCENTAJE
FROM PortafolioProject..CovidDeaths
ORDER BY PORCENTAJE DESC

--IDENTIFICANDO LOS PAISES CON LA TASA DE INFECCION POR COVID MÁS ALTA A NIVEL MUNDIAL

SELECT Location, Population, MAX(total_cases) AS TotalCases, MAX((total_cases/population))*100 AS PorcentajePobInfectada
FROM PortafolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PorcentajePobInfectada DESC

--IDENTIFICANDO LOS PAISES CON MUERTES POR COVID MAS ALTAS POR PAIS A NIVEL MUNDIAL

SELECT Location, Population, MAX(cast(total_deaths as int)) AS MaxDeaths, MAX((total_deaths/population))*100 AS PorcentajeMort
FROM PortafolioProject..CovidDeaths
WHERE continent is NOT null
GROUP BY Location, Population
ORDER BY MaxDeaths DESC, PorcentajeMort DESC

-- IDENTIFICANDO EL NUMERO DE MUERTES POR COVID POR CONTINENTE

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortafolioProject..CovidDeaths
WHERE continent is  null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- IDENTIFICANDO EL NUMERO DE MUERTES POR COVID MAS ALTAS POR PAIS DE CADA CONTINENTE

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortafolioProject..CovidDeaths
WHERE continent is  not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT Location, Population, MAX(cast(total_deaths as int)) AS MaxDeaths, MAX((total_deaths/population))*100 AS PorcentajeMort
FROM PortafolioProject..CovidDeaths
WHERE continent LIKE 'South%'
GROUP BY Location, Population
ORDER BY MaxDeaths DESC, PorcentajeMort DESC

-- NUMERO GLOBALES

SELECT Date, SUM(New_cases) AS TCases, SUM(CAST(New_deaths AS INT)) AS TDeaths, (SUM(CAST(New_deaths AS INT)))/SUM(New_cases)*100 AS DeathPercentage
FROM PortafolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY Date
ORDER BY TDeaths DESC

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortafolioProject..CovidDeaths
WHERE continent is  null
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT SUM(New_cases) AS TCases, SUM(CAST(New_deaths AS INT)) AS TDeaths, (SUM(CAST(New_deaths AS INT)))/SUM(New_cases)*100 AS DeathPercentage
FROM PortafolioProject..CovidDeaths
WHERE continent LIKE 'SOUTH%'
ORDER BY TDeaths DESC

-- COVID VACCINATIONS -- °°°°---------------°°°°----------°°°°-----------

SELECT *
FROM PortafolioProject..CovidVac
ORDER BY 3,4

SELECT *
FROM PortafolioProject..CovidDeaths AS dea 
JOIN PortafolioProject..CovidVac AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- IDENTIFICAR EL NUMERO TOTAL DE VACUNAS APLICADAS POR PAIS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location) AS TVAC
FROM PortafolioProject..CovidDeaths AS dea 
JOIN PortafolioProject..CovidVac AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- IDENTIFICAR EL NUMERO ACUMULADO DE VACUNAS APLICADAS POR PAIS PARA CADA DIA DE REGISTRO

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) AS AcumVAC
FROM PortafolioProject..CovidDeaths AS dea 
JOIN PortafolioProject..CovidVac AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- IDENTIFICAR LOS PAISES CON MAYOR NUMERO D EPERSONAS VACUNADAS SEGUN LAS FECHAS DE REGISTRO

WITH CTE_PopVsVac (Continent, Location, Date, Population, new_vaccinations, AcumVAC) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) AS AcumVAC
FROM PortafolioProject..CovidDeaths AS dea 
JOIN PortafolioProject..CovidVac AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)

SELECT *, (AcumVAC/Population)*100
FROM CTE_PopVsVac
ORDER BY 2, 3

--|||||||||||||°°°°°||||||||||||||

DROP TABLE if exists #PercentPopVacc
CREATE TABLE #PercentPopVacc (
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
new_vaccinations numeric,
AcumVAC numeric)


INSERT INTO #PercentPopVacc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) AS AcumVAC
FROM PortafolioProject..CovidDeaths AS dea 
JOIN PortafolioProject..CovidVac AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *, (AcumVAC/Population)*100
FROM #PercentPopVacc
ORDER BY 2, 3

--- CREANDO UNA VISTA PARA ALMACENAR DATA PARA VISUALIZACION 

CREATE VIEW PercentPopVacc AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) AS AcumVAC
FROM PortafolioProject..CovidDeaths AS dea 
JOIN PortafolioProject..CovidVac AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL