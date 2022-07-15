CREATE TABLE osm_waterway AS
SELECT * FROM planet_osm_line 
WHERE waterway = 'canal' 
OR waterway = 'dam' 
OR waterway = 'ditch' 
OR waterway = 'drain' 
OR waterway = 'fish_pass' 
OR waterway = 'river' 
OR waterway = 'stream';

--Tunnel und Bruecken Abschnitte wieder entfernen

DELETE FROM osm_waterway 
WHERE "bridge" = 'yes' 
OR "bridge" = 'aqueduct';

DELETE FROM osm_waterway 
WHERE "tunnel" = 'yes' 
OR "tunnel" = 'bridge'
OR "tunnel" = 'building_passage'
OR "tunnel" = 'covered'
OR "tunnel" = 'culvert'
OR "tunnel" = 'passage';

