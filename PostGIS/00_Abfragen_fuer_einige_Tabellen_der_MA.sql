--Abfragen zur Erstellung einer Tabellen dieser Arbeit


--fuer importe OSM Tabellen inklusive Speicherplatz

SELECT * FROM 
(SELECT nspname || '.' || relname AS "relation",
    pg_size_pretty(pg_total_relation_size(C.oid)) AS "total_size"
  FROM pg_class C
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE nspname NOT IN ('pg_catalog', 'information_schema')
    AND C.relkind <> 'i'
    AND nspname !~ '^pg_toast'
  ORDER BY pg_total_relation_size(C.oid) DESC) AS src
 WHERE relation LIKE 'public.planet_%';

--fuer Anzahl von Objekten einer DB Tabelle - bezogen auf die AOI Dresden
SELECT COUNT (osm.*) 
FROM  planet_osm_polygon osm, aoi_dresden aoi 
WHERE ST_Intersects(aoi.geometry, ST_Transform(osm.way, 4326));

--Liste der abgeleiteten Barrierentypen (mit semantischen Metadaten)
--Beispielabfrage fuer Bestimmung der Gesamtlaenge innerhalb AOI Dresden 
SELECT SUM (ST_Length(ST_Intersection(ST_Transform(aoi.geometry, 3857), osm.way))) 
FROM  osm_barrier osm, aoi_dresden aoi WHERE ST_Intersects(ST_Transform(aoi.geometry, 3857), osm.way);



--einige Abfragen fuer semantische, geometrische, topologische Analysen

SELECT ST_IsValid(way), COUNT(*) FROM osm_landuse GROUP BY ST_IsValid(way);

SELECT ST_IsSimple(way), COUNT(*) FROM osm_landuse GROUP BY ST_IsSimple(way);

SELECT ST_GeometryType(way), COUNT(*) FROM osm_landuse GROUP BY ST_GeometryType(way);

--Summe aller Teilgeometrien
SELECT SUM(ST_NumGeometries(geometry)) FROM osm_landuse_aoi_dresden_union_hierarchy;



--Duplikate Anzahl bestimmen (durch 2 geteilt fuer korrekte Anzahl)

SELECT COUNT(*)::float / 2
FROM osm_landuse a, osm_landuse b 
WHERE ST_Equals(a.way, b.way) AND ST_Intersects(a.way, b.way) AND a.osm_id != b.osm_id;

-- Ueberlappungen 
SELECT 
	COUNT(intersected.*) AS "anzahl_overlaps",
	SUM (ST_Area(intersected.geometry)) AS "summe_flaeche"
FROM (
	SELECT 
		(ST_Dump(ST_MakeValid(ST_Intersection(a.way, b.way)))).geom AS "geometry"
	FROM osm_landuse a, osm_landuse b  
	WHERE ST_Intersects(a.way, b.way) AND a.osm_id > b.osm_id
 ) AS intersected
WHERE ST_Dimension(intersected.geometry) = 2;

SELECT 
	COUNT(intersected.*) AS "anzahl_overlaps",
	SUM (ST_Area(ST_Transform(intersected.geometry, 3857))) AS "summe_flaeche"
FROM (
	SELECT 
		(ST_Dump(ST_MakeValid(ST_Intersection(a.way, b.way)))).geom AS "geometry"
	FROM osm_landuse_aoi_dresden a, osm_landuse_aoi_dresden b  
	WHERE ST_Intersects(a.way, b.way) AND a.osm_id > b.osm_id
 ) AS intersected
WHERE ST_Dimension(intersected.geometry) = 2;



--
Flaeche der AOI Dresden in qm erhalten (fuer anschließenden relativen Flaechenvergleich)

SELECT ST_Area(ST_Transform(a.geometry, 3857)) FROM aoi_dresden a;

--Loecher / Holes bezogen auf AOI Dresden Polygon fuer Zwischenstand

SELECT 
	COUNT(intersected.*) AS "anzahl_holes",
	SUM (ST_Area(intersected.geometry)) AS "summe_flaeche"
FROM (
	SELECT 
		(ST_Dump(ST_MakeValid(ST_Difference(ST_Transform(a.geometry, 3857), b.geometry)))).geom AS "geometry"
	FROM aoi_dresden a, 
	(SELECT ST_MakeValid(ST_Union(c.way)) AS "geometry" FROM osm_landuse c) AS b  
 ) AS intersected
WHERE ST_Dimension(intersected.geometry) = 2;

--Loecher fuer Endstand von LU Datensatz
SELECT 
	COUNT(intersected.*) AS "anzahl_holes",
	SUM (ST_Area(intersected.geometry)) AS "summe_flaeche"
FROM (
	SELECT 
		(ST_Dump(ST_MakeValid(ST_Difference(ST_MakeValid(ST_Transform(a.geometry, 3857)), ST_Transform(b.geometry, 3857))))).geom AS "geometry"
	FROM aoi_dresden a, 
	(SELECT 1 AS "id", ST_Union(ST_MakeValid(ST_Buffer(c.geometry, 0.000001))) AS "geometry" FROM osm_landuse_monitor_aoi_dresden_union_hierarchy2 c) AS b  
 ) AS intersected
WHERE ST_Dimension(intersected.geometry) = 2;



--oder auch so: (ohne lu_nr=0, also ohne Restpolygon. Dies entspricht ja bereits der AOI, es wuerde keine Loecher geben)
SELECT 
	COUNT(intersected.*) AS "anzahl_holes",
	SUM (ST_Area(intersected.geometry)) AS "summe_flaeche"
FROM (
	SELECT 
		(ST_Dump(ST_MakeValid(ST_Difference(ST_Transform(a.geometry, 3857), b.geometry)))).geom AS "geometry"
	FROM aoi_dresden a, 
	(SELECT ST_MakeValid(ST_Union(c.way)) AS "geometry" FROM osm_landuse_monitor c 
	 WHERE c.lu_nr != 0) AS b  
 ) AS intersected
WHERE ST_Dimension(intersected.geometry) = 2;


--Grafik zu Datenschema mit den vier Attributen:
SELECT * FROM osm_landuse_aoi_dresden_union ORDER BY lu_nr DESC;



-- Abbildung Bildschirmabzug Zwischenergebnis Variante GIScience Schritt Nr. 7
SELECT *, ST_GeometryType(geometry) FROM temp_7 ORDER BY lu_nr DESC;


--Auswertung LU-Datensatz nach LU-Klasse

DROP TABLE IF EXISTS auswertung_giscience;
CREATE TABLE auswertung_giscience AS
SELECT lu_nr,
	ST_NumGeometries(geometry) AS "Anzahle_Objekte",
	ROUND(CAST(ST_NumGeometries(geometry)::float AS numeric) / 21912 * 100, 2) AS "Anteil_Objekte",
	ST_Area(ST_Transform(geometry, 3857)) AS "Summe_Fläche",
	ROUND(CAST(ST_Area(ST_Transform(geometry, 3857))::float AS numeric) / 1883385333.36583 * 100, 2) AS "Anteil_Fläche"
FROM osm_landuse_aoi_dresden_union_hierarchy
ORDER BY "Anteil_Fläche" DESC;

CREATE TABLE auswertung_monitor AS
SELECT lu_nr,
	ST_NumGeometries(geometry) AS "Anzahle_Objekte",
	ROUND(CAST(ST_NumGeometries(geometry)::float AS numeric) / 45336 * 100, 2) AS "Anteil_Objekte",
	ROUND(CAST(ST_Area(ST_Transform(geometry, 3857)) AS numeric), 2) AS "Summe_Fläche",
	ROUND(CAST(ST_Area(ST_Transform(geometry, 3857))::float AS numeric) / 1883385333.36583 * 100, 2) AS "Anteil_Fläche"
FROM osm_landuse_monitor_aoi_dresden_union_hierarchy2
ORDER BY "Anteil_Fläche" DESC;



--Ueberlappungen final fuer Variante IOER Monitor
SELECT 
	(COUNT(intersected.*)::float / 2) AS "anzahl_overlaps",
	(SUM (ST_Area(ST_Transform(intersected.geometry, 3857)))::float / 2) AS "summe_flaeche"
FROM (
	SELECT 
		(ST_Dump(ST_Intersection(ST_MakeValid(a.geometry), ST_MakeValid(b.geometry)))).geom AS "geometry"
	FROM osm_landuse_monitor_aoi_dresden_union_hierarchy2 a, 
	osm_landuse_monitor_aoi_dresden_union_hierarchy2 b  
	WHERE ST_Intersects(a.geometry, b.geometry) AND a.id != b.id
 ) AS intersected
WHERE ST_Dimension(intersected.geometry) = 2;

--besser vorher mit einem negativ der AOI sowie 0.000002° Buffer ausschneiden. um topologische Fehler am Rand zu bereinigen
CREATE TABLE auswertung_monitor_final_overlaps_null_buffer_edge_aoi AS
SELECT (ST_Intersection(ST_MakeValid(ST_Buffer(a.geometry, 0.000000)), ST_MakeValid(ST_Buffer(b.geometry, 0.000000)))) AS "geometry"
FROM osm_landuse_monitor_aoi_dresden_union_hierarchy2_edge_aoi a, 
osm_landuse_monitor_aoi_dresden_union_hierarchy2_edge_aoi b  
WHERE ST_Intersects(a.geometry, b.geometry) AND a.id != b.id;
--diese Abfrage oben (auf den finalen LU Datensatz Variante IOER-Monitor) lief 9h 30min durch! letztendlich erfolgreich!


SELECT COUNT(*) / 2 AS "anzahl_overlaps",
	SUM(ST_Area(ST_Transform(geometry, 3857))) / 2 AS "flaeche_overlaps"
FROM auswertung_monitor_final_overlaps_null_buffer_edge_aoi;




-- explorative Datenanalyse
-- Anzahl eines POIs bezogen auf AOI Dresden
--genutzt wird ein zu Beginn erzeugter VIEW, welcher ein ST_Intersects() mit AOI Dresden durchfuehrt

SELECT COUNT (*) FROM view_planet_osm_point_aoi_dresden WHERE leisure='picnic_table';

SELECT COUNT (*) FROM view_planet_osm_point_aoi_dresden WHERE "tags" -> 'internet_access'='wlan';

--flaechenhafte OSM Objekte... Statistik

SELECT
	COUNT (b.*) AS "anzahl",
	ROUND(AVG(b.area)::numeric, 2) AS "area_durchschnitt",
	ROUND(MAX(b.area)::numeric, 2) AS "area_max",
	ROUND(MIN(b.area)::numeric, 2) AS "area_min",
	ROUND(stddev(b.area)::numeric, 2) AS "area_stabw"
FROM   
	(SELECT osm_id,
	 ST_Transform(a.way, 3857) AS "geometry",
	 ST_Area(ST_Transform(a.way, 3857)) AS "area"
	FROM view_planet_osm_polygon_aoi_dresden a 
	WHERE "natural"='wood') AS b;
	
	

--Analyse nach Key "barrier" 


SELECT 
	pre."Anzahl_Null",
	pre."Anzahl_NotNull",
	pre."Gesamtanzahl",
	ROUND(pre."Anzahl_NotNull"::numeric / pre."Gesamtanzahl" * 100, 2) AS "Anteil"
FROM
	(SELECT COUNT(*) FILTER (WHERE barrier IS NULL) AS "Anzahl_Null",
		COUNT(*) FILTER (WHERE barrier IS NOT NULL) AS "Anzahl_NotNull",
		COUNT(*) AS "Gesamtanzahl"
	FROM view_planet_osm_point_aoi_dresden) AS pre;
	
	
--zur Ermittlung der TOP 5 Values nach Anzahl

SELECT barrier, COUNT(barrier) AS "Anzahl"
FROM view_planet_osm_polygon_aoi_dresden
GROUP BY barrier
ORDER BY "Anzahl" DESC
LIMIT 5;


	
	
