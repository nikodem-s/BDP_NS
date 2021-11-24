SELECT ST_AREA(geom) FROM obikety
SELECt nazwa,geom FROM obikety;
DELETE FROM obikety WHERE nazwa='obiekt2'
INSERT INTO obikety VALUES
('obiekt1',ST_COLLECT(ARRAY['LINESTRING(0 1, 1 1)','CIRCULARSTRING(1 1, 2 0, 3 1)',
					  'CIRCULARSTRING(3 1, 4 2, 5 1)','LINESTRING(5 1, 6 1)']));
--geometry ST_GeomFromEWKT(text EWKT) tworzy obiket ST_GEOMETERY, musze zawsze dac SRID=0,
--ST_COLLECt nie dziala tu za bardzo
--CURVEPOLYGON towrzy zakrecony pokligon, a compund sumuje to wszystko w jedno
INSERT INTO obikety VALUES
('obiekt2',ST_GeomFromEWKT('SRID=0;CURVEPOLYGON(COMPOUNDCURVE(LINESTRING(10 6, 14 6),
						   CIRCULARSTRING(14 6, 16 4, 14 2),
							CIRCULARSTRING(14 2, 12 0, 10 2), LINESTRING(10 2, 10 6)),
						     CIRCULARSTRING(11 2, 13 2, 11 2))'));

INSERT INTO obikety VALUES(
'obiekt3','POLYGON((10 17, 12 13, 7 15, 10 17))')
--obiekt 4
INSERT INTO obikety VALUES(
'obiekt4',ST_COLLECT(ARRAY[
'LINESTRING(20 20, 25 25)',
'LINESTRING(25 25, 27 24)',
'LINESTRING(27 24, 25 22)',
'LINESTRING(25 22, 26 21)',
'LINESTRING(26 21, 22 19)',
'LINESTRING(22 19, 20.5 19.5)'
	]))
	--POINTM to punkt w przestrzeni 3d, ale ja tu chce zeby byly dwa punkty jako jeden obiekt wiec
	--MUTIPOINTM
INSERT INTO obikety VALUES(
'obiekt 5','MULTIPOINTM((30 30 59),(38 32 234))')

INSERT INTO obikety VALUES(
'obiekt6',ST_COLLECT('LINESTRING(1 1, 3 2)','POINT(4 2)'))

--zadanie1, DISTINCT temu zeby niepotrzebnie duplikowały się
SELECT DISTINCT ST_LENGTH(ST_SHORTESTLINE((SELECT geom FROM obikety WHERE 
nazwa='obiekt3'),(SELECT geom FROM obikety WHERE nazwa='obiekt4')))
FROM obikety 
--zadanie2
SELECT ST_IsClosed(geom) FROM obikety WHERE nazwa = 'obiekt4'
SELECT * FROM obikety;
--teraz UPDATE
UPDATE obikety
		SET geom =ST_UNION(geom,(ST_AddPoint('LINESTRING(22 19, 20.5 19.5)', ST_StartPoint('LINESTRING(20 20, 25 25)'))))
		WHERE nazwa = 'obiekt4';
		--funkcja St_AddPoint pozwala na stworzenie tej linii laczcej dzieki ktorej zamkne poligon
		--funkcja ST_Union pozwala jakby zeby zlaczyc ta linie, ktora tworze by zamknac poligon
		--i poprzednia geometrie
		
		--drugi update zeby przetrasferowac ta figure na poligon
UPDATE obikety
		SET geom = ST_MakePolygon(ST_LineMerge(geom))
		WHERE nazwa = 'obiekt4'
		
--DELETE FROM obikety WHERE nazwa='obiekt4'
SELECT ST_AREA(geom) FROM obikety WHERE nazwa='obiekt4'
SELECT ST_IsClosed(geom),nazwa FROM obikety 
SELECT ST_AsText(ST_LineMerge(geom)) FROM obikety WHERE nazwa = 'obiekt4'
--zadanie3
SELECT ST_UNION((SELECT geom FROM obikety WHERE nazwa='obiekt3'),(SELECT geom FROM obikety WHERE nazwa='obiekt4'));
INSERT INTO obikety VALUES
('obeikt7',(SELECT ST_UNION((SELECT geom FROM obikety WHERE nazwa='obiekt3'),(SELECT geom FROM obikety WHERE nazwa='obiekt4'))))
SELECT * FROM obikety WHERE nazwa='obeikt7'
--zad4
SELECT ST_HasArc(geom) FROM obikety where nazwa='obiekt1';
SELECT ST_BUFFER(geom,5) FROM obikety WHERE ST_HasArc(geom) = 'false' AND nazwa = 'obiekt1';
--rozwiazanie:
SELECT SUM(ST_AREA(ST_BUFFER(geom,5))) as "Pole" FROM obikety WHERE ST_HasArc(geom) = 'false';
INSERT into obikety VALUES
('obiekt_test','CIRCULARSTRING(11 2, 13 2, 11 2)')
SELECT ST_AREA(geom) FROM obikety WHERE nazwa='obiekt_test'
DELETE FROM obikety WHERE nazwa='obiekt_test'

SELECT * FROM obikety;
