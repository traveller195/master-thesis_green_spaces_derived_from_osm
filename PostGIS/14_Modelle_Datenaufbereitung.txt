--Datenaufbereitung fuer die beiden Modelle "Gruenheit" und "Zugaenglichkeit"

--Datenimport in Terminal von Container "ma_import_01"

ogr2ogr -f "PostgreSQL" PG:"dbname='osm' host='ma_db_01' port='5432' user='postgres' password='postgres'" "nutzung_flurstueck.geojson" -nln nutzung_flurstueck -lco GEOMETRY_NAME=geometry -nlt geometry

--Warning 1: Renaming field 'oid' to 'oid_' to avoid conflict with internal oid field.
--nun weiter in PostGIS
--die Daten bezueglich nutzart gruppieren zum Kennenlernen des Datensatzes


SELECT nutzart, COUNT(*) AS "Anzahl" FROM nutzung_flurstueck GROUP BY nutzart ORDER BY "Anzahl" DESC;





--Daten auf Analyse BBox reduzieren und transformieren


DROP TABLE IF EXISTS nutzung_flurstueck_bbox;
CREATE TABLE nutzung_flurstueck_bbox AS
SELECT a.ogc_fid,
	a.oid_,
	a.flstkennz,
	a.nutzart,
	ST_Transform(a.geometry, 3857) AS "geometry"
FROM nutzung_flurstueck a, aoi_dresden_bbox b
WHERE ST_Intersects(a.geometry, ST_Transform(b.geometry, 25833));


SELECT nutzart, COUNT(*) AS "Anzahl" FROM nutzung_flurstueck_bbox GROUP BY nutzart ORDER BY "Anzahl" DESC;


--neues Attribut fuer output anlegen
ALTER TABLE nutzung_flurstueck_bbox
ADD COLUMN out INTEGER;


UPDATE nutzung_flurstueck_bbox SET out = 1 WHERE nutzart = 'Wald';
UPDATE nutzung_flurstueck_bbox SET out = 1 WHERE nutzart = 'Friedhof';
UPDATE nutzung_flurstueck_bbox SET out = 1 WHERE nutzart = 'Gehölz';
UPDATE nutzung_flurstueck_bbox SET out = 1 WHERE nutzart = 'Sport-, Freizeit- und Erholungsfläche';
--alle anderen auf Null setzen

UPDATE nutzung_flurstueck_bbox SET out = 0 WHERE out IS NULL;

--Check

SELECT COUNT(*), out FROM nutzung_flurstueck_bbox GROUP BY out;


--Attribute fuer die Eingabe-Variablen erstellen:

ALTER TABLE nutzung_flurstueck_bbox
ADD COLUMN in_1 INTEGER;
ALTER TABLE nutzung_flurstueck_bbox
ADD COLUMN in_2 INTEGER;
ALTER TABLE nutzung_flurstueck_bbox
ADD COLUMN in_3 INTEGER;
ALTER TABLE nutzung_flurstueck_bbox
ADD COLUMN in_4 INTEGER;
ALTER TABLE nutzung_flurstueck_bbox
ADD COLUMN in_5 INTEGER;
ALTER TABLE nutzung_flurstueck_bbox
ADD COLUMN in_6 INTEGER;
ALTER TABLE nutzung_flurstueck_bbox
ADD COLUMN in_7 INTEGER;
ALTER TABLE nutzung_flurstueck_bbox
ADD COLUMN in_8 INTEGER;
ALTER TABLE nutzung_flurstueck_bbox
ADD COLUMN in_9 INTEGER;
								
-- jeweils die Anzahl fuer verschiedene OSM POI berechnen und zuweisen
--beginnen mit den haeufigsten vertretenen POIs im Datenbestand --> sind aum vielversprechendsten
UPDATE nutzung_flurstueck_bbox dest 
SET in_1=(SELECT COUNT(*) FROM planet_osm_point src WHERE ST_Intersects(dest.geometry, ST_Transform(src.way, 3857)) AND src.amenity='bench');

UPDATE nutzung_flurstueck_bbox dest 
SET in_3=(SELECT COUNT(*) FROM planet_osm_point src WHERE ST_Intersects(dest.geometry, ST_Transform(src.way, 3857)) AND src."natural"='tree');


UPDATE nutzung_flurstueck_bbox dest 
SET in_4=(SELECT COUNT(*) FROM planet_osm_point src WHERE ST_Intersects(dest.geometry, ST_Transform(src.way, 3857)) AND src."amenity"='waste_basket');


UPDATE nutzung_flurstueck_bbox dest 
SET in_8=(SELECT COUNT(*) FROM planet_osm_point src WHERE ST_Intersects(dest.geometry, ST_Transform(src.way, 3857)) AND src."amenity"='toilets');
				
		
UPDATE nutzung_flurstueck_bbox dest 
SET in_9=(SELECT COUNT(*) FROM planet_osm_point src WHERE ST_Intersects(dest.geometry, ST_Transform(src.way, 3857)) AND src."tags" -> 'internet_access'='wlan');


UPDATE nutzung_flurstueck_bbox dest 
SET in_2=(SELECT COUNT(*) FROM planet_osm_point src WHERE ST_Intersects(dest.geometry, ST_Transform(src.way, 3857)) AND src."leisure"='picnic_table');


		


-- Datenaufbereitung von Stadt Dresden kommunaler Flächen

CREATE TABLE komm_flaechen_bbox AS
SELECT a.fid,
	a.id,
	a.fsk,
	a.fsn_zae,
	a.fsn_nen,
	a.eigentum_status,
	ST_Transform(a.geometry, 3857)
FROM flst_anfragepiraten_2020_03_24_alle_4326 a, aoi_dresden_bbox b
WHERE ST_Intersects(a.geometry, b.geometry);

ALTER TABLE komm_flaechen_bbox
RENAME COLUMN st_transform TO geometry;

--neues Attribut fuer output anlegen

ALTER TABLE komm_flaechen_bbox
ADD COLUMN out INTEGER;

-- output zuweisen

UPDATE komm_flaechen_bbox SET out = 1 WHERE eigentum_status = 'A';
UPDATE komm_flaechen_bbox SET out = 0 WHERE eigentum_status != 'A';
UPDATE komm_flaechen_bbox SET out = 0 WHERE eigentum_status IS NULL;

-- Test bezeuglich 'out'

SELECT out, COUNT(*) FROM komm_flaechen_bbox GROUP BY out;

-- Polygon des Großen Gartens entfernen, da es zwar oeffentlich zugaenglich ist, aber nicht in kommunaler Hand 
DELETE FROM komm_flaechen_bbox WHERE fid=80170;

--Attribute fuer die Eingabe-Variablen erstellen:

ALTER TABLE komm_flaechen_bbox
ADD COLUMN in_1 INTEGER;
ALTER TABLE komm_flaechen_bbox
ADD COLUMN in_2 INTEGER;
ALTER TABLE komm_flaechen_bbox
ADD COLUMN in_3 INTEGER;
ALTER TABLE komm_flaechen_bbox
ADD COLUMN in_4 INTEGER;
ALTER TABLE komm_flaechen_bbox
ADD COLUMN in_5 INTEGER;
ALTER TABLE komm_flaechen_bbox
ADD COLUMN in_6 INTEGER;
ALTER TABLE komm_flaechen_bbox
ADD COLUMN in_7 INTEGER;
ALTER TABLE komm_flaechen_bbox
ADD COLUMN in_8 INTEGER;
ALTER TABLE komm_flaechen_bbox
ADD COLUMN in_9 INTEGER;

-- jeweils die Anzahl fuer verschiedene OSM POI berechnen und zuweisen
--beginnen mit den haeufigsten vertretenen POIs im Datenbestand --> sind aum vielversprechendsten
UPDATE komm_flaechen_bbox dest 
SET in_1=(SELECT COUNT(*) FROM planet_osm_point src WHERE ST_Intersects(dest.geometry, ST_Transform(src.way, 3857)) AND src.amenity='bench');

UPDATE komm_flaechen_bbox dest 
SET in_3=(SELECT COUNT(*) FROM planet_osm_point src WHERE ST_Intersects(dest.geometry, ST_Transform(src.way, 3857)) AND src."natural"='tree');

UPDATE komm_flaechen_bbox dest 
SET in_4=(SELECT COUNT(*) FROM planet_osm_point src WHERE ST_Intersects(dest.geometry, ST_Transform(src.way, 3857)) AND src."amenity"='waste_basket');

UPDATE komm_flaechen_bbox dest 
SET in_8=(SELECT COUNT(*) FROM planet_osm_point src WHERE ST_Intersects(dest.geometry, ST_Transform(src.way, 3857)) AND src."amenity"='toilets');



UPDATE komm_flaechen_bbox dest 
SET in_9=(SELECT COUNT(*) FROM planet_osm_point src WHERE ST_Intersects(dest.geometry, ST_Transform(src.way, 3857)) AND src."tags" -> 'internet_access'='wlan');


UPDATE komm_flaechen_bbox dest 
SET in_2=(SELECT COUNT(*) FROM planet_osm_point src WHERE ST_Intersects(dest.geometry, ST_Transform(src.way, 3857)) AND src."leisure"='picnic_table');

