CREATE DATABASE cw2NS;

CREATE EXTENSION postgis;

--tworzenie tabelek
CREATE TABLE BUILDINGS(
	id INT PRIMARY KEY,
	geometry GEOMETRY(POLYGON),
	name VARCHAR(40)
);

CREATE TABLE ROADS(
	id INT PRIMARY KEY,
	geometry GEOMETRY(LINESTRING),
	name VARCHAR(40)
	);
CREATE TABLE POI(
	id INT PRIMARY KEY,
	geometry GEOMETRY,
	name VARCHAR(40)
);
--usuniecie tabelki
DROP TABLE ROADS;
DROP TABLE BUILDINGS;
DROP TABLE POI;
--Dodawanie rekordów do tabeli POI
INSERT INTO POI VALUES(1,'POINT(1 3.5)','G');
INSERT INTO POI VALUES(2,'POINT(5.5 1.5)','H');
INSERT INTO POI VALUES(3,'POINT(9.5 6)','I');
INSERT INTO POI VALUES(4,'POINT(6.5 6)','J');
INSERT INTO POI VALUES(5,'POINT(6 9.5)','K');
--wyswietlenie tabelki. dlaczego w kolumnie GEOMETRY takie dziwne? rozw:uzyc ST_AsText!
SELECT ST_AsText(geometry) AS Geometria FROM POI;
--Dodawanie rekordów do tabeli ROADS
INSERT INTO ROADS VALUES(1,'LINESTRING(0 4.5, 7.5 4.5, 12 4.5)','RoadX'); --pamietaj o przecinkach przy LINESTRING
INSERT INTO ROADS VALUES(2,'LINESTRING(7.5 0, 7.5 4.5, 7.5 10.5)','RoadY');
SELECT * FROM ROADS,POI;
--Dodawanie rekordów do tabeli BUILDINGS
INSERT INTO BUILDINGS VALUES(1,'POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))','BuildingA');
INSERT INTO BUILDINGS VALUES(2,'POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))','BuildingB');
INSERT INTO BUILDINGS VALUES(3,'POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))','BuildingC');
INSERT INTO BUILDINGS VALUES(4,'POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))','BuildingD');
INSERT INTO BUILDINGS VALUES(5,'POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))','BuildingF');
--pamietaj o podwojnych nawiasach kiedy dodajesz POLYGONS! bez nich nie zadziala
--przecinki rowniez musza byc postawione jak tu, inaczej wywala
SELECT * FROM BUILDINGS;

--Cwiczenie 1, calkowita dlugosc drog
SELECT SUM(ST_LENGTH(geometry)) AS "Dlugosc drog" FROM ROADS;
--Cwiczenie 2, obwod i Pp Budynku A
SELECT ST_PERIMETER(geometry) AS "Obwod",ST_AREA(geometry) AS "Pole" FROM BUILDINGS WHERE name='BuildingA';
--Cwiczenie 3							 
SELECT name AS "Nazwa", ST_AREA(geometry) AS "Pole" FROM BUILDINGS ORDER BY name ASC; 
--za so sortowane ORDER BY
--Cwiczenie 4
SELECT ST_PERIMETER(geometry) AS "Obwod" FROM BUILDINGS ORDER BY ST_PERIMETER(geometry) DESC LIMIT 2;
--Cwiczenie 5
SELECT ST_DISTANCE(BUILDINGS.geometry,POI.geometry) AS "Dystans"
FROM POI INNER JOIN BUILDINGS ON POI.name='G'
AND BUILDINGS.name='BuildingC';
--ale czy to najkrotsze?
--Cwiczenie6
 SELECT ST_AREA(ST_DIFFERENCE((SELECT geometry FROM BUILDINGS WHERE name='BuildingC'),
					 (SELECT ST_BUFFER(geometry,0.5,'endcap=flat') FROM BUILDINGS WHERE name ='BuildingB')));
--Cwiczenie7
SELECT name,ST_Y(ST_CENTROID(geometry)), geometry as "Wspolrzedna X" FROM BUILDINGS WHERE ST_Y(ST_CENTROID(geometry)) >=4.5;
--funkcja ST_Y i ST_X wyciaga jedna wspolrzedna z punktu, w zaleznsoci od tego czy mamy X czy Y w nazwie
--cwiczenie8
SELECT ST_AREA(ST_SYMDIFFERENCE('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'::geometry, geometry)) FROM
BUILDINGS WHERE name='BuildingC';
--ST_SYMDIFFERENCE usuwa jakby ta czesc ktora sie pokrywa w tych dwoch figurach
--TEST SYMDIFFERENCE zeby zobaczyc czy to dobrze dziala
SELECT (ST_SYMDIFFERENCE('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'::geometry, geometry)) FROM
BUILDINGS WHERE name='BuildingC';
