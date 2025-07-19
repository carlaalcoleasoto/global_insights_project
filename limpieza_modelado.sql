-- Conteo de registros
SELECT
 (SELECT COUNT(*) FROM country) AS total_country,
 (SELECT COUNT(*) FROM city) AS total_city,
 (SELECT COUNT(*) FROM countrylanguage) AS total_countrylanguage,
 (
   (SELECT COUNT(*) FROM country) +
   (SELECT COUNT(*) FROM city) + 
   (SELECT COUNT(*) FROM countrylanguage)
 ) AS total_general;
 
 -- Visualización de primeras filas
SELECT * FROM country LIMIT 5;
SELECT * FROM city LIMIT 5;
SELECT * FROM countrylanguage LIMIT 5;

-- Verificar duplicados
SELECT Name, COUNT(*) FROM country GROUP BY Name HAVING COUNT(*) > 1;
SELECT Name, COUNT(*) FROM city GROUP BY Name HAVING COUNT(*) > 1;

-- ¿En cuántos países aparece cada idioma?
SELECT Language, COUNT(DISTINCT CountryCode) AS num_paises
FROM countrylanguage GROUP BY Language ORDER BY num_paises DESC;

-- Vamos a ver la estructura de las tablas para detectar nulos.
-- 1. Estructura de la tabla COUNTRY
DESCRIBE country;

-- Comprobación de valores nulos en la tabla `country`
SELECT 
  SUM(CASE WHEN IndepYear IS NULL THEN 1 ELSE 0 END) AS null_IndepYear,
  SUM(CASE WHEN LifeExpectancy IS NULL THEN 1 ELSE 0 END) AS null_LifeExpectancy,
  SUM(CASE WHEN GNP IS NULL THEN 1 ELSE 0 END) AS null_GNP,
  SUM(CASE WHEN GNPOld IS NULL THEN 1 ELSE 0 END) AS null_GNPOld,
  SUM(CASE WHEN HeadOfState IS NULL THEN 1 ELSE 0 END) AS null_HeadOfState,
  SUM(CASE WHEN Capital IS NULL THEN 1 ELSE 0 END) AS null_Capital
FROM country;

-- Creación de tabla limpia
CREATE OR REPLACE VIEW country_clean AS
SELECT *
FROM country
WHERE LifeExpectancy IS NOT NULL
  AND Capital IS NOT NULL;

-- Validación
SELECT COUNT(*) FROM country;
SELECT COUNT(*) FROM country_clean;

-- 2. Estructura de la tabla CITY
DESCRIBE city;

-- ¿Hay ciudades con población cero?
SELECT COUNT(*) AS cities_with_zero_population
FROM city
WHERE Population = 0;

-- ¿Campos vacíos en DISTRICT o Name?
SELECT *
FROM city
WHERE Population = 0 OR District = '' OR Name = '';

-- Vista limpia de la tabla city
CREATE OR REPLACE VIEW city_clean AS
SELECT *
FROM city
WHERE Name IS NOT NULL AND Name <> ''
  AND District IS NOT NULL AND District <> ''
  AND CountryCode IS NOT NULL;
  
-- Validación
SELECT COUNT(*) FROM city;
SELECT COUNT(*) FROM city_clean;

-- 3. Estructura de la tabla COUNTRYLANGUAGE
DESCRIBE countrylanguage;

-- Verificación de valores vacíos o atípicos
SELECT *
FROM countrylanguage
WHERE CountryCode = ''
   OR Language = ''
   OR IsOfficial NOT IN ('T', 'F')
   OR Percentage < 0;

-- Lenguas con 0%
SELECT COUNT(*) AS langs_with_zero_percentage
FROM countrylanguage
WHERE Percentage = 0;

-- Vista limpia de la tabla countrylanguage
CREATE OR REPLACE VIEW countrylanguage_clean AS
SELECT *
FROM countrylanguage;

-- Validación (aunque no debería haber cambios, se hace por mantener estructura)
SELECT COUNT(*) FROM countrylanguage;
SELECT COUNT(*) FROM countrylanguage_clean;

-- Verificar que todas las ciudades están asignadas a un país existente
SELECT *
FROM city_clean c
LEFT JOIN country co ON c.CountryCode = co.Code
WHERE co.Code IS NULL;

-- Verificar que todos los idiomas están asignados a países válidos
SELECT *
FROM countrylanguage cl
LEFT JOIN country co ON cl.CountryCode = co.Code
WHERE co.Code IS NULL;