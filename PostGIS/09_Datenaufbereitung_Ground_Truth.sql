--Datenaufbereitung fuer Ground-Truth

-- Liniendatensaetze werden gemaess Datenschema fuer den Ground-Truth erweitert
-- diese Attribute ebenfalls analog anhaengen fuer osm_railway, osm_street, osm_trail, osm_waterway

-- da Datentype hstore nicht nach GeoJSON exportiert werden kann, eine neue Spalte als varchar anlegen und Daten konvertieren
SET search_path TO public;
CREATE TABLE ground_truth_osm_barrier AS
SELECT osm.* FROM osm_barrier osm, aoi_dresden aoi
  WHERE st_intersects(aoi.geometry, st_transform(osm.way, 4326));
  
ALTER TABLE ground_truth_osm_barrier ALTER COLUMN tags TYPE json 
USING hstore_to_json(tags);

ALTER TABLE ground_truth_osm_barrier ADD COLUMN tags_text VARCHAR;
UPDATE ground_truth_osm_barrier SET tags_text = tags #>> '{}';

ALTER TABLE ground_truth_osm_barrier DROP COLUMN tags;

ALTER TABLE ground_truth_osm_barrier ADD COLUMN barriere VARCHAR;
ALTER TABLE ground_truth_osm_barrier ADD COLUMN "comment" VARCHAR;
ALTER TABLE ground_truth_osm_barrier ADD COLUMN lastEdit TIMESTAMP;
ALTER TABLE ground_truth_osm_barrier ADD COLUMN type_bar VARCHAR;
ALTER TABLE ground_truth_osm_barrier ADD COLUMN fee_bar VARCHAR;
ALTER TABLE ground_truth_osm_barrier ADD COLUMN fence VARCHAR;
ALTER TABLE ground_truth_osm_barrier ADD COLUMN wall VARCHAR;


--> noch auf Gebiet der AOI aus Tabelle "ground_truth_grober_extent" clippen!


--nun die Landnutzungswechsel aus der Variante IOER Monitor erzeugen
-- jeweils die gemeinsame Grenz als Linie verwenden

-- auf einen groben Extent clippen
CREATE TABLE osm_landuse_monitor_aoi_dresden_union_hierarchy2_ground AS 
SELECT osm.*, ST_Intersection(aoi.geometry, ST_Transform(osm.geometry, 4326)) AS "geometry2"
FROM  osm_landuse_monitor_aoi_dresden_union_hierarchy2 osm, ground_truth_grober_extent aoi 
WHERE ST_Intersects(aoi.geometry, ST_Transform(osm.geometry, 4326));



ALTER TABLE osm_landuse_monitor_aoi_dresden_union_hierarchy2_ground
DROP COLUMN geometry;

ALTER TABLE osm_landuse_monitor_aoi_dresden_union_hierarchy2_ground
RENAME COLUMN geometry2 TO geometry;


--Multipolygone zu simple Geometrien mit ST_Dump()
CREATE TABLE osm_landuse_monitor_aoi_dresden_union_hierarchy2_ground_dump AS
SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "id", 
	a.lu_nr, 
	a.lu_type, 
	(ST_Dump(a.geometry)).geom AS "geometry"
FROM osm_landuse_monitor_aoi_dresden_union_hierarchy2_ground a;



--Spatial Index

CREATE INDEX osm_landuse_monitor_aoi_dresden_union_hierarchy2_ground_dump_idx
  ON osm_landuse_monitor_aoi_dresden_union_hierarchy2_ground_dump
  USING GIST (geometry);



-- die eigentliche Ermittlung der Grenzlinien

CREATE TABLE ground_truth_osm_landuse2 AS
SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "id",
	a.lu_nr AS "a_lu_nr", 
	a.lu_type AS "a_lu_type", 
	b.lu_nr AS "b_lu_nr", 
	b.lu_type AS "b_lu_type", 
	ST_Intersection(a.geometry, b.geometry) AS "geometry"
FROM osm_landuse_monitor_aoi_dresden_union_hierarchy2_ground_dump a, 
osm_landuse_monitor_aoi_dresden_union_hierarchy2_ground_dump b
WHERE ST_Intersects(a.geometry, b.geometry) AND a.id != b.id;


--Ausgabe der erzeugten Geometrie-Typen

SELECT ST_GeometryType(a.geometry) as "Geometry-Type", 
COUNT (ST_GeometryType(a.geometry)) as Anzahl 
FROM ground_truth_osm_landuse a GROUP BY ST_GeometryType(a.geometry);


--Abfrage des Flaecheninhaltes der Slivers-Polygone im WGS84

SELECT *, ST_Area(geometry) AS "Area" FROM ground_truth_osm_landuse2 
WHERE ST_GeometryType(geometry) = 'ST_Polygon' OR ST_GeometryType(geometry) = 'ST_Multipolygon'
ORDER BY "Area" DESC;


--Entscheidungsbaum zur Abarbeitung der entstandenen Geometrietypen
-- Punkte und Multipunkte werden ignoriert
-- Multilinien und Multipolygone zu simplen Geometrien
-- Linien koennen uebernommen werden
--Polygone werden durch die ihre laengste Kante ersetzt

--Nun zuerst alle Simple Linien in eine neue Tabelle:
CREATE TABLE ground_truth_osm_landuse2_lines AS
SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "id", 
	clipped.a_lu_nr AS "a_lu_nr", 
	clipped.a_lu_type AS "a_lu_type", 
	clipped.b_lu_nr AS "b_lu_nr", 
	clipped.b_lu_type AS "b_lu_type", 
	clipped.geometry AS "geometry"
FROM (
	SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "id",
		t1.a_lu_nr AS "a_lu_nr", 
		t1.a_lu_type AS "a_lu_type", 
		t1.b_lu_nr AS "b_lu_nr", 
		t1.b_lu_type AS "b_lu_type",
		(ST_Dump(t1.geometry)).geom AS "geometry"
	 FROM ground_truth_osm_landuse2 t1         
 ) AS clipped
WHERE ST_Dimension(clipped.geometry) = 1;


--alle Polygone in eine extra Tabelle
CREATE TABLE ground_truth_osm_landuse2_polygone AS
SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "id", 
	clipped.a_lu_nr AS "a_lu_nr", 
	clipped.a_lu_type AS "a_lu_type", 
	clipped.b_lu_nr AS "b_lu_nr", 
	clipped.b_lu_type AS "b_lu_type", 
	clipped.geometry AS "geometry"
FROM (
	SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "id",
		t1.a_lu_nr AS "a_lu_nr", 
		t1.a_lu_type AS "a_lu_type", 
		t1.b_lu_nr AS "b_lu_nr", 
		t1.b_lu_type AS "b_lu_type",
		(ST_Dump(t1.geometry)).geom AS "geometry"
	 FROM ground_truth_osm_landuse2 t1         
 ) AS clipped
WHERE ST_Dimension(clipped.geometry) = 2;


--anstelle Polygon die laengste Kante als Liniengeometrie verwenden
INSERT INTO ground_truth_osm_landuse2_lines 
SELECT 
	lines.id AS "id",
	lines.a_lu_nr AS "a_lu_nr", 
	lines.a_lu_type AS "a_lu_type", 
	lines.b_lu_nr AS "b_lu_nr", 
	lines.b_lu_type AS "b_lu_type", 
	lines.geometry AS "geometry"
FROM (
	SELECT 
		t1.id AS "id",
		t1.a_lu_nr AS "a_lu_nr", 
		t1.a_lu_type AS "a_lu_type", 
		t1.b_lu_nr AS "b_lu_nr", 
		t1.b_lu_type AS "b_lu_type",
		(SELECT t3.geometry AS "geometry"
		 FROM (SELECT (ST_Dump(ST_Split(ST_Boundary(t2.geometry), (ST_DumpPoints(t2.geometry)).geom))).geom AS "geometry"
			   FROM  ground_truth_osm_landuse2_polygone t2
			   WHERE t2.id=t1.id
		 		 ) AS t3
		 ORDER BY ST_Length(t3.geometry) DESC
		 LIMIT 1) AS "geometry"
	FROM ground_truth_osm_landuse2_polygone t1
	WHERE ST_NPoints(t1.geometry)= 4
 ) AS lines
 
 
