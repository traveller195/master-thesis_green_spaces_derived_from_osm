CREATE TABLE osm_trail AS
SELECT * FROM planet_osm_line 
WHERE highway = 'bridleway' 
OR highway = 'cycleway' 
OR highway = 'footway' 
OR highway = 'no' 
OR highway = 'path' 
OR highway = 'track';

--Tunnel und Bruecken Abschnitte wieder entfernen

DELETE FROM osm_trail 
WHERE "tunnel" = 'yes' 
OR "tunnel" = 'passage' 
OR "tunnel" = 'culvert'
OR "tunnel" = 'covered'
OR "tunnel" = 'building_passage';

DELETE FROM osm_trail 
WHERE "bridge" = 'yes' 
OR "bridge" = 'viaduct' 
OR "bridge" = 'cantilever'
OR "bridge" = 'boardwalk';


