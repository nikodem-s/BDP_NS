--ST_REMOVE... nie dziala jak chce dlatego wzialem SELECT DISTINCT
--DISTNICT nie dziala z COUNT, wyswietla 34 rekordy nadal, kiedy powinno 31 jak w wersji z DISTANCE
--SELECT COUNT(ST_REMOVEREPEATEDPOINTS(popp.geom)) FROM rivers,popp WHERE 
--ST_CONTAINS((ST_BUFFER(rivers.geom,1000)), popp.geom)  = TRUE AND popp.f_codedesc = 'Building';

--cwiczenie 1 punkt4

--wersja z CONTAINS
SELECT DISTINCT COUNT(popp.geom) FROM rivers,popp WHERE 
ST_CONTAINS((ST_BUFFER(rivers.geom,1000)), popp.geom)  = TRUE AND popp.f_codedesc = 'Building';
--wersja z distance
SELECT DISTINCT popp.gid,popp.geom FROM rivers,popp WHERE 
ST_DISTANCE(rivers.geom, popp.geom) < 1000 AND popp.f_codedesc = 'Building';
--dodanie do osobnej tabelki
CREATE TABLE TabelaB(
	gid INT, --dodaj jako PRIMARY KEY jak znajdziesz jak usunac zduplikowane wiersze
	cat FLOAT,
	f_codedesc VARCHAR(80),
	type VARCHAR(80),
	f_code VARCHAR(80),
	geom GEOMETRY
);
DROP TABLE TabelaB;
--Dodanie rekordow to tabelkiB poprzez SELECT, wtedy on pelni jakby role brakuajcego VALUES.
INSERT INTO TabelaB(gid,cat,f_codedesc,f_code,type,geom)
SELECT DISTINCT popp.gid,popp.cat,popp.f_codedesc,popp.f_code,popp.type,popp.geom FROM rivers,popp WHERE 
ST_DISTANCE(rivers.geom, popp.geom) < 1000 AND popp.f_codedesc = 'Building';
-- testy, rozne wyswietlania.
SELECT * FROM TabelaB;
SELECT COUNT(rivers.geom) FROM rivers;
SELECT * FROM rivers;
SELECT * FROM popp;
SELECT COUNT(*) FROM popp WHERE f_codedesc = 'Building';
SELECT COUNT(*) FROM popp WHERE f_codedesc = 'Building';
SELECT * FROM airports;
SELECT * FROM airportsNew;
SELECT St_X(geom),geom FROM airports WHERE name ='NOATAK';
--koniec testow

--cwiczenie2 punkt5

--tworzenie tabelki airportsNEW
CREATE TABLE airportsNew(
	name VARCHAR(80),
	elev NUMERIC,
	geometry GEOMETRY
);
--wlozenie rekordow do tabelki airPortsNew
INSERT INTO airportsNew(name,elev,geometry)
SELECT name,elev,geom FROM airports;

--najbardziej na wschod i zachod, uzylem union all zeby sprawidzc jak wyglada to wizualnie
(SELECT ST_X(geometry),geometry,name FROM airportsNew ORDER BY st_x desc LIMIT 1)
UNION ALL
(SELECT ST_X(geometry), geometry,name FROM airportsNew ORDER BY st_x asc LIMIT 1);
--uzylem nazw lotnisk, ktore poznalem w zapytaniu wyzej
SELECT ST_CENTROID(ST_MAKELINE((SELECT (geometry)FROM airportsNew WHERE name='ANNETTE ISLAND')
				   ,(SELECT (geometry)FROM airportsNew WHERE name='ATKA')));
--Dodanie rekordu do tabelki
INSERT INTO airportsNew(geometry)
--INSERT INTO airportsNew(geometry) WHERE name = 'airportB'
SELECT ST_CENTROID(ST_MAKELINE((SELECT (geometry)FROM airportsNew WHERE name='ANNETTE ISLAND')
				   ,(SELECT (geometry)FROM airportsNew WHERE name='ATKA')));
--DELETE FROM airportsNew WHERE name = 'airportB';

UPDATE airportsNew
SET name = 'airportB'
WHERE name ISNULL;

UPDATE airportsNew
SET elev = 100
WHERE elev ISNULL;

--cwiczenie 3 punkt6
SELECT * FROM lakes;
SELECT * FROM airports;
SELECT ST_AREA(ST_BUFFER(ST_SHORTESTLINE((SELECT ST_CENTROID(geom) FROM lakes WHERE names = 'Iliamna Lake')
				  ,(SELECT geom FROM airports WHERE name='AMBLER')),1000));

--cwiczenie 4 punkt7
SELECT * FROM tundra;
SELECT * FROM swamp;
SELECT * FROM trees;
SELECT SUM(area_km2),vegdesc FROM trees GROUP BY vegdesc;
--Dziele na milion, zeby miec km^2, bo st_area w geometry daje wynik w m^2
--SELECT SUM(ST_AREA(ST_INTERSECTION(trees.geom,swamp.geom)))/1000000 AS "Bagna",
--SUM(ST_AREA(ST_INTERSECTION(trees.geom,tundra.geom)))/1000000 AS "Tundra"
--FROM trees,swamp,tundra GROUP BY vegdesc;

--inna proba
--SELECT SUM(trees.area_km2),vegdesc FROM trees,swamp WHERE ST_CONTAINS(
--swamp.geom,trees.geom) = TRUE GROUP BY vegdesc;
--chyba dobrze
SELECT vegdesc, SUM(ST_AREA(trees.geom))/1000000 FROM trees,swamp,tundra WHERE
ST_CONTAINS(tundra.geom,trees.geom) OR ST_CONTAINS(swamp.geom,trees.geom) GROUP BY vegdesc;

