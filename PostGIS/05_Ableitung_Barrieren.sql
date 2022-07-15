--Selektion von allen gesetzten Werten fuer Key "barrier" (außer NULL)
--Selektion von Linien und Polygone
CREATE TABLE osm_barrier AS
SELECT * FROM planet_osm_line 
WHERE barrier IS NOT NULL;

--neues Attribut "origin" fuer originalen Geometrietyp
ALTER TABLE osm_barrier 
ADD COLUMN origin VARCHAR;

UPDATE osm_barrier SET origin='Line';

--Polygone in temporaere Tabelle laden
CREATE TABLE osm_barrier_temp AS
SELECT *, ST_ExteriorRing(way) as way2 
FROM planet_osm_polygon 
WHERE barrier IS NOT NULL;

ALTER TABLE osm_barrier_temp DROP COLUMN way;
ALTER TABLE osm_barrier_temp RENAME COLUMN way2 TO way;

ALTER TABLE osm_barrier_temp ADD COLUMN origin VARCHAR;
UPDATE osm_barrier_temp SET origin='Polygon';

--Zusammenfuehren
INSERT INTO osm_barrier SELECT * FROM osm_barrier_temp;

-- temporaere Tabelle entfernen
DROP TABLE osm_barrier_temp;

--aufgrund Zusammenfuehrung auf geometrische Duplikate pruefen
SELECT a.osm_id, b.osm_id, a.barrier, b.barrier
FROM osm_barrier a, osm_barrier b 
WHERE ST_Equals(a.way, b.way) AND a.osm_id != b.osm_id;

