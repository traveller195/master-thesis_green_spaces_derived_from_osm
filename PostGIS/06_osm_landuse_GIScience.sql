-- Ableitung eines OSM Landuse/Landcover Datensatzes basierend auf GIScience Heidelberg
CREATE TABLE osm_landuse AS
SELECT * FROM planet_osm_polygon WHERE "landuse" = 'forest' 
UNION
SELECT * FROM planet_osm_polygon WHERE "natural" = 'wood';

--Attribut "lu_type" hinzufuegen

ALTER TABLE osm_landuse ADD COLUMN lu_type VARCHAR;
UPDATE osm_landuse SET "lu_type"='forest';

INSERT INTO osm_landuse
SELECT *, 'water' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'basin' 
UNION
SELECT *, 'water' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'reservoir' 
UNION
SELECT *, 'water' as "lu_type" FROM planet_osm_polygon WHERE "waterway" = 'dock' 
UNION
SELECT *, 'water' as "lu_type" FROM planet_osm_polygon WHERE "waterway" = 'canal' 
UNION
SELECT *, 'water' as "lu_type" FROM planet_osm_polygon WHERE "waterway" = 'pond' 
UNION
SELECT *, 'water' as "lu_type" FROM planet_osm_polygon WHERE "waterway" = 'riverbank' 
UNION
SELECT *, 'water' as "lu_type" FROM planet_osm_polygon WHERE "natural" = 'water';



INSERT INTO osm_landuse
SELECT *, 'shrub' as "lu_type" FROM planet_osm_polygon WHERE "natural" = 'grass' 
UNION
SELECT *, 'shrub' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'grass' 
UNION
SELECT *, 'shrub' as "lu_type" FROM planet_osm_polygon WHERE "natural" = 'grassland' 
UNION
SELECT *, 'shrub' as "lu_type" FROM planet_osm_polygon WHERE "natural" = 'scrub' 
UNION
SELECT *, 'shrub' as "lu_type" FROM planet_osm_polygon WHERE "natural" = 'heath' 
UNION
SELECT *, 'shrub' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'greenfield';


INSERT INTO osm_landuse
SELECT *, 'urban_fabric' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'residential' 
UNION
SELECT *, 'urban_fabric' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'garages';


INSERT INTO osm_landuse
SELECT *, 'industrial_commercial_transport' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'industrial' 
UNION
SELECT *, 'industrial_commercial_transport' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'commercial' 
UNION
SELECT *, 'industrial_commercial_transport' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'railway' 
UNION
SELECT *, 'industrial_commercial_transport' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'retail' 
UNION
SELECT *, 'industrial_commercial_transport' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'harbour' 
UNION
SELECT *, 'industrial_commercial_transport' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'port' 
UNION
SELECT *, 'industrial_commercial_transport' as "lu_type" FROM planet_osm_polygon WHERE "water" = 'lock' 
UNION
SELECT *, 'industrial_commercial_transport' as "lu_type" FROM planet_osm_polygon WHERE "leisure" = 'marina';


INSERT INTO osm_landuse
SELECT *, 'mine_dump_construction' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'quarry' 
UNION
SELECT *, 'mine_dump_construction' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'construction' 
UNION
SELECT *, 'mine_dump_construction' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'landfill' 
UNION
SELECT *, 'mine_dump_construction' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'brownfield';



INSERT INTO osm_landuse
SELECT *, 'artificial_non_agri_vegetated' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'recreation_ground' 
UNION
SELECT *, 'artificial_non_agri_vegetated' as "lu_type" FROM planet_osm_polygon WHERE "leisure" = 'stadium' 
UNION
SELECT *, 'artificial_non_agri_vegetated' as "lu_type" FROM planet_osm_polygon WHERE "leisure" = 'golf_course' 
UNION
SELECT *, 'artificial_non_agri_vegetated' as "lu_type" FROM planet_osm_polygon WHERE "leisure" = 'sports_centre' 

UNION
SELECT *, 'artificial_non_agri_vegetated' as "lu_type" FROM planet_osm_polygon WHERE "leisure" = 'playground'
UNION
SELECT *, 'artificial_non_agri_vegetated' as "lu_type" FROM planet_osm_polygon WHERE "leisure" = 'pitch'
UNION
SELECT *, 'artificial_non_agri_vegetated' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'village_green'
UNION
SELECT *, 'artificial_non_agri_vegetated' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'allotments'

UNION
SELECT *, 'artificial_non_agri_vegetated' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'cemetery'
UNION
SELECT *, 'artificial_non_agri_vegetated' as "lu_type" FROM planet_osm_polygon WHERE "leisure" = 'park'
UNION
SELECT *, 'artificial_non_agri_vegetated' as "lu_type" FROM planet_osm_polygon WHERE "tourism" = 'zoo'
UNION
SELECT *, 'artificial_non_agri_vegetated' as "lu_type" FROM planet_osm_polygon WHERE "leisure" = 'track'

UNION
SELECT *, 'artificial_non_agri_vegetated' as "lu_type" FROM planet_osm_polygon WHERE "leisure" = 'garden'
UNION
SELECT *, 'artificial_non_agri_vegetated' as "lu_type" FROM planet_osm_polygon WHERE "highway" = 'raceway';



INSERT INTO osm_landuse
SELECT *, 'arable_land' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'greenhouse' 
UNION
SELECT *, 'arable_land' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'greenhouse_horticulture' 
UNION
SELECT *, 'arable_land' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'farmland' 
UNION
SELECT *, 'arable_land' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'farm' 

UNION
SELECT *, 'arable_land' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'farmyard';



INSERT INTO osm_landuse
SELECT *, 'permanent_crops' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'orchard' 
UNION
SELECT *, 'permanent_crops' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'vineyard';



INSERT INTO osm_landuse
SELECT *, 'pastures' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'meadow';


INSERT INTO osm_landuse
SELECT *, 'open_space_little_or_no_vegetation ' as "lu_type" FROM planet_osm_polygon WHERE "natural" = 'cliff' 
UNION
SELECT *, 'open_space_little_or_no_vegetation ' as "lu_type" FROM planet_osm_polygon WHERE "natural" = 'sand' 
UNION
SELECT *, 'open_space_little_or_no_vegetation ' as "lu_type" FROM planet_osm_polygon WHERE "natural" = 'scree' 
UNION
SELECT *, 'open_space_little_or_no_vegetation ' as "lu_type" FROM planet_osm_polygon WHERE "natural" = 'beach' 
UNION
SELECT *, 'open_space_little_or_no_vegetation ' as "lu_type" FROM planet_osm_polygon WHERE "natural" = 'mud' 
UNION
SELECT *, 'open_space_little_or_no_vegetation ' as "lu_type" FROM planet_osm_polygon WHERE "natural" = 'glacier' 
UNION
SELECT *, 'open_space_little_or_no_vegetation ' as "lu_type" FROM planet_osm_polygon WHERE "natural" = 'rock' 
UNION
SELECT *, 'open_space_little_or_no_vegetation ' as "lu_type" FROM planet_osm_polygon WHERE "natural" = 'fell';


INSERT INTO osm_landuse
SELECT *, 'inland_wetlands' as "lu_type" FROM planet_osm_polygon WHERE "natural" = 'wetland'
UNION
SELECT *, 'inland_wetlands' as "lu_type" FROM planet_osm_polygon WHERE "wetland" = 'marsh';


INSERT INTO osm_landuse
SELECT *, 'coastal_wetlands' as "lu_type" FROM planet_osm_polygon WHERE "landuse" = 'salt_pond'
UNION
SELECT *, 'coastal_wetlands' as "lu_type" FROM planet_osm_polygon WHERE "tidal" = 'yes';


--Daten exakt auf AOI Dresden beschneiden

CREATE TABLE osm_landuse_aoi_dresden AS 
SELECT osm.*, ST_Intersection(aoi.geometry, ST_Transform(osm.way, 4326)) AS "way2"
FROM  osm_landuse osm, aoi_dresden aoi 
WHERE ST_Intersects(aoi.geometry, ST_Transform(osm.way, 4326));

--neue Geometriespalte aufbereiten

ALTER TABLE osm_landuse_aoi_dresden
DROP COLUMN way;

ALTER TABLE osm_landuse_aoi_dresden
RENAME COLUMN way2 TO way;



--ebenfalls eine Spalte "lu_nr" mit ganzzahliger LU Klassennummer ergaenzen. Analog zu IOER Monitor Datensatz
--dieser dient ebenfalls als Hierarchie fuer Verschneidung der Klassen

ALTER TABLE osm_landuse_aoi_dresden 
ADD COLUMN lu_nr INTEGER; 

UPDATE osm_landuse_aoi_dresden SET lu_nr = 1 WHERE lu_type = 'urban_fabric';
UPDATE osm_landuse_aoi_dresden SET lu_nr = 2 WHERE lu_type = 'industrial_commercial_transport';
UPDATE osm_landuse_aoi_dresden SET lu_nr = 3 WHERE lu_type = 'mine_dump_construction';
UPDATE osm_landuse_aoi_dresden SET lu_nr = 4 WHERE lu_type = 'artificial_non_agri_vegetated';
UPDATE osm_landuse_aoi_dresden SET lu_nr = 5 WHERE lu_type = 'arable_land';
UPDATE osm_landuse_aoi_dresden SET lu_nr = 6 WHERE lu_type = 'permanent_crops';
UPDATE osm_landuse_aoi_dresden SET lu_nr = 7 WHERE lu_type = 'pastures';
UPDATE osm_landuse_aoi_dresden SET lu_nr = 8 WHERE lu_type = 'forest';
UPDATE osm_landuse_aoi_dresden SET lu_nr = 9 WHERE lu_type = 'shrub';
UPDATE osm_landuse_aoi_dresden SET lu_nr = 10 WHERE lu_type = 'open_space_little_or_no_vegetation ';
UPDATE osm_landuse_aoi_dresden SET lu_nr = 11 WHERE lu_type = 'inland_wetlands';
UPDATE osm_landuse_aoi_dresden SET lu_nr = 12 WHERE lu_type = 'coastal_wetlands';
UPDATE osm_landuse_aoi_dresden SET lu_nr = 13 WHERE lu_type = 'water'; 

--auch wenn coastal_wetland in AOI Dresden nicht existieren, werden sie hier beruecksichtigt

--Geometrien je LU-Klasse (GROUP BY) vereinigen, um je LU-Klasse Überlappungen zu entfernen
--da neue Geometrien gebildet werden, auch neue UUID vergeben

CREATE TABLE osm_landuse_aoi_dresden_union AS
SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "id", 
lu_nr, lu_type, ST_Union(a.way) AS "geometry"
FROM osm_landuse_aoi_dresden a
GROUP BY lu_nr, lu_type;




-- Restpolygon = AOI Dresden hinzufuegen, mit lu_nr = 0. Bedeutet, es ist die unterste Schicht beim Verschneiden
--HINWEIS: nun CRS EPSG-Code 4326 anstelle vorher 3857 (wurde zu spaet bemerkt)

INSERT INTO osm_landuse_aoi_dresden_union
SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "id", 
0 AS lu_nr, 'outer' AS lu_type, a.geometry AS geometry FROM aoi_dresden a;


--nun die Function Clip_by_Hierarchie ausfuehren. Entsprechende Tabellen fuer Input setzen
--siehe naechstes Skript
