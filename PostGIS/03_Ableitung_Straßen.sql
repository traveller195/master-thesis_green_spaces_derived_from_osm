CREATE TABLE osm_street AS
SELECT * FROM planet_osm_line 
WHERE highway = 'construction' 
OR highway = 'living_street' 
OR highway = 'motorway' 
OR highway = 'motorway_link' 
OR highway = 'pedestrian' 
OR highway = 'platform' 
OR highway = 'primary' 
OR highway = 'primary_link' 
OR highway = 'raceway' 
OR highway = 'residential' 
OR highway = 'road' 
OR highway = 'secondary' 
OR highway = 'secondary_link' 
OR highway = 'service' 
OR highway = 'steps' 
OR highway = 'tertiary' 
OR highway = 'tertiary_link' 
OR highway = 'trunk' 
OR highway = 'trunk_link' 
OR highway = 'unclassified';

--Tunnel und Bruecken Abschnitte wieder entfernen

DELETE FROM osm_street 
WHERE "tunnel" = 'yes' 
OR "tunnel" = 'covered' 
OR "tunnel" = 'culvert' 
OR "tunnel" = 'building_passage';

DELETE FROM osm_street 
WHERE "bridge" = 'yes' 
OR "bridge" = 'cantilever' 
OR "bridge" = 'viaduct';


