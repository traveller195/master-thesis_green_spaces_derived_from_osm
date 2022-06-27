--Aufbereitung fuer Diagramme und Analysen

--zunaechst eine BoundingBox fuer Vermaschung und Analysen festlegen


CREATE TABLE aoi_dresden_bbox AS 
SELECT 1 AS "id", ST_GeomFromText('POLYGON ((13.7131 51.0315, 13.8032 51.0315, 13.8032 51.1, 13.7131 51.1, 13.7131 51.0315))', 4326) AS "geometry";


--neue Tabelle fuer den sog. Linien-Pool deklarieren. 
--Aus diesem Linien-Pool werden  

CREATE TABLE linien_pool (
	id UUID,
	origin VARCHAR,
	likelihood NUMERIC,
	buffer NUMERIC,
	geometry GEOMETRY
);

--Pufferbreiten fuer Strassen und Bahnstrecken setzen

ALTER TABLE osm_street
ADD COLUMN buffer NUMERIC;

UPDATE osm_street SET buffer = 5.25 WHERE highway = 'motorway';
UPDATE osm_street SET buffer = 3.00 WHERE highway != 'motorway';


ALTER TABLE osm_railway
ADD COLUMN buffer NUMERIC;

UPDATE osm_railway SET buffer = 2.25 WHERE railway = 'tram';
UPDATE osm_railway SET buffer = 3.75 WHERE railway != 'tram';



--an Wege die Barrierenwahrscheinlichkeit anspielen, ebenfalls die Pufferweiten 

ALTER TABLE osm_trail
ADD COLUMN likelihood NUMERIC;

UPDATE osm_trail dest SET likelihood = src.anteil_yes_laenge
FROM trail_likelihood src
WHERE dest.highway=src.highway;

--ALTER TABLE osm_trail
--ADD COLUMN buffer NUMERIC;

-- alle abgeleiteten Barrieren gemaess Annahmen hinzufuegen
-- likelihood p = 1 --> 100% Barriere

--Strassen
INSERT INTO linien_pool
SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "id",
	'osm_street' AS "origin",
	1 AS "likelihood",
	a.buffer AS "buffer",
	a.way AS "geometry"
FROM osm_street a;

--Wasserwege
INSERT INTO linien_pool
SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "id",
	'osm_waterway' AS "origin",
	1 AS "likelihood",
	1 AS "buffer",
	a.way AS "geometry"
FROM osm_waterway a;


--Barrieren (OSM key=barrier)
INSERT INTO linien_pool
SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "id",
	'osm_barrier' AS "origin",
	1 AS "likelihood",
	0 AS "buffer",
	a.way AS "geometry"
FROM osm_barrier a;

--Bahnstrecken
INSERT INTO linien_pool
SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "id",
	'osm_railway' AS "origin",
	1 AS "likelihood",
	a.buffer AS "buffer",
	a.way AS "geometry"
FROM osm_railway a;

--Wege
INSERT INTO linien_pool
SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "id",
	'osm_trail' AS "origin",
	a.likelihood AS "likelihood",
	1 AS "buffer",
	a.way AS "geometry"
FROM osm_trail a;

-- kurz die CRS / SRID pruefen, welche in dem Linien-Pool schon enthalten sind

SELECT ST_SRID(geometry), COUNT(*) AS "anzahl" FROM linien_pool GROUP BY ST_SRID(geometry);	
-- alle Geometrielosen Zeilen loeschen (es gab einen Fehler dort)

DELETE FROM linien_pool WHERE ST_SRID(geometry) IS NULL;


-- die LU Wechsel Linien vorbereiten:
-- von den fehlerhaften Duplikaten befreien, durch a_lu_type > b_lu_type. Nur eine Richtung zulassen in der LU-Kombination

--CRS pruefen 
SELECT ST_SRID(geometry), COUNT(*) AS "anzahl" FROM ground_truth_osm_landuse2_lines GROUP BY ST_SRID(geometry);	
-- sie liegen in WGS84 vor und muessen noch transformiert werden nach 3857

--nun alles in einem Schritt erledigen: 
--Duplikate durch a.a_lu_nr > a.b_lu_nr entfernen
--in WebMercator EPSG-Code: 3857 transformieren
--gleich korrekte Wahrscheinlichkeit anhaengen

CREATE TABLE osm_lu_wechsel AS
SELECT a.id AS "id",
	a.a_lu_nr AS "a_lu_nr",
	a.b_lu_nr AS "b_lu_nr",
	ST_Transform(a.geometry, 3857) AS "geometry",
	(SELECT "anteil_yes_laenge" FROM lu_change_likelihood b WHERE b.a2_lu_nr=a.a_lu_nr AND b.b2_lu_nr=a.b_lu_nr) AS "likelihood"
FROM ground_truth_osm_landuse2_lines a
WHERE a.a_lu_nr > a.b_lu_nr;

--Annahme treffen: falls diese LU-Kombination nicht erfasst wurde, dann soll es eine Barriere mit p=1 sein
--deshalb nun alle NULL Werte bei likelihood entsprechend abändern

UPDATE osm_lu_wechsel SET likelihood = 1 WHERE likelihood IS NULL;

--und nun zum linien_pool hinzufuegen

INSERT INTO linien_pool
SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "id",
	'lu_change' AS "origin",
	a.likelihood AS "likelihood",
	0 AS "buffer",
	a.geometry AS "geometry"
FROM osm_lu_wechsel a;

--fuer Analysegebiet auf eine gewaehlte BBox begrenzen (inkl. ST_Intersection() also dem exakten Verschneiden der Geometrie)

CREATE TABLE linien_pool_bbox AS
SELECT 
	dumped.id AS "id",
	dumped.origin AS "origin",
	dumped.buffer AS "buffer",
	dumped.likelihood AS "likelihood",
	dumped.geometry AS "geometry"
FROM (
	SELECT a.id AS "id",
		a.origin AS "origin", 
		a.buffer AS "buffer",
		a.likelihood AS "likelihood",
		(ST_Dump(ST_Intersection(ST_Transform(bbox.geometry, 3857), a.geometry))).geom AS "geometry" 
	FROM aoi_dresden_bbox bbox, linien_pool a
	WHERE ST_Intersects(ST_Transform(bbox.geometry, 3857), a.geometry)) AS dumped
WHERE ST_Dimension(dumped.geometry) = 1;



-- den ST_ExteriorRing() der BBox als aussere Begrenzung ebenfalls als Linie hinzufuegen (mit buffer =0 und likelihood = 1)

INSERT INTO linien_pool_bbox
SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "id",
	'bbox' AS "origin",
	0 AS "buffer",
	1 AS "likelihood",
	ST_ExteriorRing(ST_Transform(a.geometry, 3857)) AS "geometry"
FROM aoi_dresden_bbox a;

--kurze Auswertung zu ANzahl und Gesamtlaenge (ohne BBox Grenzlinie)
SELECT COUNT(*), SUM(ST_Length(geometry)) FROM linien_pool_bbox WHERE origin != 'bbox';



-- nun die Vermaschung beginnen (mit allen Barrieren)

CREATE TABLE polygonize_all AS
SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "id",
	dumped.geometry AS "geometry"
FROM (
	SELECT (ST_Dump(polygonized.geometry)).geom AS "geometry"
	FROM (
		SELECT ST_Polygonize(unified.geometry) AS "geometry"
		FROM (
			SELECT ST_Union(src.geometry) AS "geometry" FROM linien_pool_bbox src
		) AS unified
	) AS polygonized
) AS dumped	
WHERE ST_Dimension(dumped.geometry) = 2;

-- mit Pufferlayer Differenz bilden

CREATE TABLE polygonize_all_buffered AS
SELECT
	dumped.id AS "id",
	dumped.geometry AS "geometry"
FROM (
	SELECT differenced.id AS "id",
			(ST_Dump(differenced.geometry)).geom AS "geometry"
	FROM (
			SELECT poly.id AS "id",
				ST_Difference(poly.geometry, buffered.geometry) AS "geometry"
			FROM (
				SELECT ST_Union(ST_Buffer(b.geometry, b.buffer)) AS "geometry" 
				FROM linien_pool_bbox b WHERE b.buffer > 0
			) AS buffered,
				polygonize_all poly
		) differenced
	) AS dumped

WHERE ST_Dimension(dumped.geometry) = 2;

--> nun entsprechende Varianten der Vermaschung fuer p >= 0.2, 0.4, 0.6 , 0.8 und = 1 bilden

CREATE TABLE polygonize_0_2 AS
SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "id",
	dumped.geometry AS "geometry"
FROM (
	SELECT (ST_Dump(polygonized.geometry)).geom AS "geometry"
	FROM (
		SELECT ST_Polygonize(unified.geometry) AS "geometry"
		FROM (
			SELECT ST_Union(src.geometry) AS "geometry" FROM linien_pool_bbox src WHERE src.likelihood >= 0.2
		) AS unified
	) AS polygonized
) AS dumped	
WHERE ST_Dimension(dumped.geometry) = 2;
	
CREATE TABLE polygonize_0_2_buffered AS
SELECT
	dumped.id AS "id",
	dumped.geometry AS "geometry"
FROM (
	SELECT differenced.id AS "id",
			(ST_Dump(differenced.geometry)).geom AS "geometry"
	FROM (
			SELECT poly.id AS "id",
				ST_Difference(poly.geometry, buffered.geometry) AS "geometry"
			FROM (
				SELECT ST_Union(ST_Buffer(b.geometry, b.buffer)) AS "geometry" 
				FROM linien_pool_bbox b WHERE b.buffer > 0 AND b.likelihood >= 0.2
			) AS buffered,
				polygonize_0_2 poly
		) differenced
	) AS dumped

WHERE ST_Dimension(dumped.geometry) = 2;

