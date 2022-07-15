CREATE TABLE osm_railway AS
SELECT * FROM planet_osm_line 
WHERE railway='construction' 
OR railway='disused' 
OR railway='facility' 
OR railway='funicular' 
OR railway='miniature' 
OR railway='narrow_gauge' 
OR railway='platform' 
OR railway='platform_edge' 
OR railway='preserved' 
OR railway='rail' 
OR railway='tram' 
OR railway='tram_stop' 
OR railway='turntable';

--Tunnel und Bruecken Abschnitte wieder entfernen

DELETE FROM osm_railway 
WHERE "bridge" = 'yes' 
OR "bridge" = 'viaduct' 
OR "bridge" = 'cantilever';

DELETE FROM osm_railway 
WHERE "tunnel" = 'yes' 
OR "tunnel" = 'building_passage';

-- Schraegaufzuege hinzufuegen (Linienzug nicht geschlossen). Dagegen Fahrstuehle (geschlossener Linienzug / Rechteck) per WHERE Klausel ausschliessen

INSERT INTO osm_railway
SELECT * FROM planet_osm_line WHERE highway='elevator' AND ST_IsClosed(way)=false;




