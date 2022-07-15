--LU Klassen anlegen und fuellen

DROP TABLE IF EXISTS osm_landuse_monitor;

CREATE TABLE osm_landuse_monitor AS
SELECT * FROM planet_osm_polygon WHERE 1 = 2;

ALTER TABLE osm_landuse_monitor ADD COLUMN lu_type VARCHAR;
ALTER TABLE osm_landuse_monitor ADD COLUMN lu_nr INTEGER;



INSERT INTO osm_landuse_monitor 
SELECT *, 'Straßenverkehr' as "lu_type", 1 as "lu_nr"  FROM planet_osm_polygon WHERE
highway='service' OR 
highway='pedestrian' OR 
highway='footway' OR 
highway='platform' OR 
highway='rest_area' OR 
highway='services' OR 
barrier='toll_booth' OR 
public_transport='stop_area' OR 
amenity='bicycle_parking' OR 
amenity='bicycle_repair_station' OR 
amenity='bicycle_rental' OR 
amenity='bus_station' OR 
amenity='charging_station' OR 
amenity='motorcycle_parking' OR 
amenity='parking' OR 
amenity='parking_space' OR 
amenity='taxi' OR 
building='transportation';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Bahnverkehr' as "lu_type", 2 as "lu_nr"  FROM planet_osm_polygon WHERE
landuse='railway' OR 
public_transport='platform' OR 
public_transport='station' OR 
railway='platform' OR 
railway='station' OR 
railway='turntable' OR 
railway='roundhouse' OR 
railway='traverser' OR 
railway='wash' OR 
building='train_station';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Flugverkehr' as "lu_type", 3 as "lu_nr"  FROM planet_osm_polygon WHERE
aeroway='aerodrome' OR 
aeroway='apron' OR 
aeroway='hangar' OR 
aeroway='helipad' OR 
aeroway='heliport' OR 
aeroway='spaceport' OR 
aeroway='terminal' OR 
building='hangar';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Wohnbau' as "lu_type", 10 as "lu_nr"  FROM planet_osm_polygon WHERE
landuse='residential' OR 
building='apartments' OR 
building='cabin' OR 
building='detached' OR 
building='dormitory' OR 
building='farm' OR 
building='ger' OR 
building='house' OR 
building='houseboat' OR 
building='residential' OR 
building='semidetached_house' OR 
building='static_caravan' OR 
building='terrace';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Mischnutzung' as "lu_type", 11 as "lu_nr"  FROM planet_osm_polygon WHERE
landuse='garages' OR 
building='hut' OR 
building='shed' OR 
building='carport' OR 
building='garage' OR 
building='garages' OR 
building='bridge' OR 
building='container' OR 
building='marquee';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Besondere funktionale Prägung' as "lu_type", 12 as "lu_nr"  FROM planet_osm_polygon WHERE
tags -> 'emergency'='ambulance_station' OR 
tags -> 'emergency'='landing_site' OR 
tags -> 'emergency'='lifeguard' OR 
tags -> 'emergency'='assembly_point' OR 
historic='building' OR 
historic='castle' OR 
historic='church' OR 
historic='city_gate' OR 
historic='aqueduct' OR 
historic='fort' OR 
historic='manor' OR 
historic='memorial' OR 
historic='monastery' OR 
historic='monument' OR 
historic='ruins' OR 
historic='ship' OR 
landuse='education' OR 
landuse='depot' OR 
landuse='religious' OR 
aerialway='station' OR 
barrier='city_wall' OR 
historic='city_gate' OR 
historic='citywalls' OR 
tags -> 'healthcare' IS NOT NULL OR 
man_made='lighthouse' OR 
man_made='observatory' OR 
man_made='telescope' OR 
man_made='pier' OR 
man_made='tower' OR 
man_made='water_well' OR 
man_made='water_tap' OR 
office='diplomatic' OR 
office='educational_institution' OR 
office='employment_agency' OR 
office='forestry' OR 
office='government' OR 
office='political_party' OR 
office='religion' OR 
office='research' OR 
office='visa' OR 
tourism='attraction' OR 
tourism='artwork' OR 
tourism='information' OR 
amenity='college' OR 
amenity='driving_school' OR 
amenity='kindergarten' OR 
amenity='language_school' OR 
amenity='library' OR 
amenity='toy_library' OR 
amenity='music_school' OR 
amenity='school' OR 
amenity='university' OR 
amenity='baby_hatch' OR 
amenity='clinic' OR 
amenity='dentist' OR 
amenity='doctors' OR 
amenity='hospital' OR 
amenity='nursing_home' OR 
amenity='pharmacy' OR 
amenity='social_facility' OR 
amenity='veterinary' OR 
amenity='arts_centre' OR 
amenity='planetarium' OR 
amenity='public_bookcase' OR 
amenity='social_centre' OR 
amenity='courthouse' OR 
amenity='embassy' OR 
amenity='fire_station' OR 
amenity='police' OR 
amenity='post_depot' OR 
amenity='post_office' OR 
amenity='prison' OR 
amenity='ranger_station' OR 
amenity='townhall' OR 
amenity='give_box' OR 
amenity='shelter' OR 
amenity='shower' OR 
amenity='toilets' OR 
amenity='childcare' OR 
amenity='funeral_hall' OR 
amenity='kitchen' OR 
amenity='monastery' OR 
amenity='place_of_mourning' OR 
amenity='place_of_worship' OR 
amenity='refugee_site' OR 
leisure='bandstand' OR 
leisure='bird_hide' OR 
leisure='common' OR 
leisure='sports_centre' OR 
leisure='stadium' OR 
leisure='summer_camp' OR 
building='cathedral' OR 
building='chapel' OR 
building='church' OR 
building='monastery' OR 
building='mosque' OR 
building='presbytery' OR 
building='religious' OR 
building='shrine' OR 
building='synagogue' OR 
building='temple' OR 
building='bakehouse' OR 
building='civic'  OR 
building='fire_station' OR 
building='government' OR 
building='hospital' OR 
building='public' OR 
building='toilets' OR 
building='kindergarten' OR 
building='school' OR 
building='university' OR 
building='college' OR 
building='grandstand' OR 
building='pavilion' OR 
building='riding_hall' OR 
building='sports_hall' OR 
building='stadium' OR 
building='parking' OR 
building='gatehouse' OR 
building='ruins';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Industrie- u. Gewerbefläche' as "lu_type", 13 as "lu_nr"  FROM planet_osm_polygon WHERE
landuse='commercial' OR 
landuse='industrial' OR 
landuse='retail' OR 
landuse='port' OR 
man_made='chimney' OR 
man_made='communications_tower' OR 
man_made='crane' OR 
man_made='mineshaft' OR 
man_made='monitoring_station' OR 
man_made='pumping_station' OR 
man_made='silo' OR 
man_made='storage_tank' OR 
man_made='street_cabinet' OR 
man_made='tailings_pond' OR 
man_made='wastewater_plant' OR 
man_made='watermill' OR 
man_made='water_tower' OR 
man_made='water_works' OR 
man_made='windmill' OR 
man_made='works' OR 
tags -> 'craft' IS NOT NULL OR 
landuse='military' OR 
military IS NOT NULL  OR 
building='military' OR 
office='accountant' OR 
office='advertising_agency' OR 
office='architect' OR 
office='association' OR 
office='charity' OR 
office='company' OR 
office='consulting' OR 
office='courier' OR 
office='coworking' OR 
office='energy_supplier' OR 
office='engineer' OR 
office='estate_agent' OR 
office='financial' OR 
office='financial_advisor' OR 
office='foundation' OR 
office='graphic_design' OR 
office='guide' OR 
office='harbour_master' OR 
office='insurance' OR 
office='it' OR 
office='lawyer' OR 
office='logistics' OR 
office='moving_company' OR 
office='newspaper' OR 
office='ngo' OR 
office='notary' OR 
office='property_management' OR 
office='quango' OR 
office='surveyor' OR 
office='tax_advisor' OR 
office='telecommunication' OR 
office='water_utility' OR 
office='yes' OR 
power IS NOT NULL OR 
shop IS NOT NULL OR 
tags -> 'telecom' IS NOT NULL OR 
tourism='alpine_hut' OR 
tourism='apartment' OR 
tourism='aquarium' OR 
tourism='chalet' OR 
tourism='gallery' OR 
tourism='guest_house' OR 
tourism='hostel' OR 
tourism='hotel' OR 
tourism='motel' OR 
tourism='museum' OR 
tourism='wilderness_hut' OR 
waterway='dam' OR 
waterway='weir' OR 
waterway='fuel' OR 
amenity='bar' OR 
amenity='biergarten' OR 
amenity='cafe' OR 
amenity='fast_food' OR 
amenity='food_court' OR 
amenity='ice_cream' OR 
amenity='pub' OR 
amenity='restaurant' OR 
amenity='car_rental' OR 
amenity='car_sharing' OR 
amenity='car_wash' OR 
amenity='vehicle_inspection' OR 
amenity='ferry_terminal' OR 
amenity='fuel' OR 
amenity='bank' OR 
amenity='bureau_de_change' OR 
amenity='brothel' OR 
amenity='casino' OR 
amenity='cinema' OR 
amenity='community_centre' OR 
amenity='conference_centre' OR 
amenity='events_venue' OR 
amenity='gambling' OR 
amenity='love_hotel' OR 
amenity='nightclub' OR 
amenity='stripclub' OR 
amenity='studio' OR 
amenity='swingerclub' OR 
amenity='theatre' OR 
amenity='recycling' OR 
amenity='waste_transfer_station' OR 
amenity='animal_boarding' OR 
amenity='animal_shelter' OR 
amenity='crematorium' OR 
amenity='dive_centre' OR 
amenity='hunting_stand' OR 
amenity='internet_cafe' OR 
amenity='marketplace' OR 
leisure='adult_gaming_centre' OR 
leisure='amusement_arcade' OR 
leisure='beach_resort' OR 
leisure='dance' OR 
leisure='disc_golf_course' OR 
leisure='escape_game' OR 
leisure='fitness_centre' OR 
leisure='hackerspace' OR 
leisure='horse_riding' OR 
leisure='ice_rink' OR 
leisure='water_park' OR 
building='hotel' OR 
building='commercial' OR 
building='industrial' OR 
building='kiosk' OR 
building='office' OR 
building='retail' OR 
building='supermarket' OR 
building='warehouse' OR 
building='digester' OR 
building='service' OR 
building='transformer_tower' OR 
building='water_tower' OR 
building='bunker' OR 
building='roof';


INSERT INTO osm_landuse_monitor 
SELECT *, 'Park, Grünanlage' as "lu_type", 20 as "lu_nr"  FROM planet_osm_polygon WHERE
landuse='flowerbed' OR 
amenity='fountain' OR 
leisure='garden' OR 
leisure='park';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Kleingarten' as "lu_type", 21 as "lu_nr"  FROM planet_osm_polygon WHERE
landuse='allotments';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Wochenendsiedlung' as "lu_type", 22 as "lu_nr"  FROM planet_osm_polygon WHERE
building='bungalow';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Golfplatz' as "lu_type", 23 as "lu_nr"  FROM planet_osm_polygon WHERE
sport='golf' OR 
leisure='miniature_golf' OR
leisure='golf_course';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Sonstige Sport, Freizeit, Erholung: Spielplatz, Spielbereich' as "lu_type", 24 as "lu_nr"  FROM planet_osm_polygon WHERE
amenity='kneipp_water_cure' OR 
leisure='fitness_station' OR 
leisure='playground';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Sonstige Sport, Freizeit, Erholung: Sportplatz, Sportanlage' as "lu_type", 25 as "lu_nr"  FROM planet_osm_polygon WHERE
landuse='recreation_ground' OR 
leisure='pitch' OR 
(sport IS NOT NULL AND sport != 'golf' AND building != 'yes') OR 
amenity='public_bath' OR 
leisure='swimming_pool' OR 
leisure='swimming_area' OR 
leisure='track';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Sonstige Sport, Freizeit, Erholung: Rasen, Gras (ohne Agrar)' as "lu_type", 26 as "lu_nr"  FROM planet_osm_polygon WHERE
landuse='grass' OR 
landuse='village_green';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Sonstige Sport, Freizeit, Erholung: sonstige' as "lu_type", 27 as "lu_nr"  FROM planet_osm_polygon WHERE
tourism='camp_site' OR 
tourism='camp_pitch' OR 
tourism='caravan_site' OR 
tourism='picnic_site' OR 
tourism='zoo' OR 
tourism='theme_park' OR 
tourism='viewpoint' OR 
amenity='bbq' OR 
amenity='dog_toilet' OR 
leisure='dog_park' OR 
leisure='firepit' OR 
leisure='fishing';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Friedhof' as "lu_type", 28 as "lu_nr"  FROM planet_osm_polygon WHERE
landuse='cemetery' OR 
amenity='grave_yard';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Sonstige Siedlungsfreifläche' as "lu_type", 29 as "lu_nr"  FROM planet_osm_polygon WHERE
landuse='construction' OR 
landuse='greenfield' OR 
landuse='brownfield' OR 
barrier='hedge' OR 
barrier='wall' OR 
man_made='breakwater' OR 
man_made='bunker_silo' OR 
man_made='gasometer' OR 
building='construction';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Abbau- und Haldenfläche' as "lu_type", 30 as "lu_nr"  FROM planet_osm_polygon WHERE
landuse='landfill' OR 
landuse='quarry';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Ackerland' as "lu_type", 40 as "lu_nr"  FROM planet_osm_polygon WHERE
landuse='farmland';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Grünland' as "lu_type", 41 as "lu_nr"  FROM planet_osm_polygon WHERE
landuse='meadow' OR 
"natural"='grassland';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Streuobst / Obstbau' as "lu_type", 43 as "lu_nr"  FROM planet_osm_polygon WHERE
landuse='orchard';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Weinbau' as "lu_type", 45 as "lu_nr"  FROM planet_osm_polygon WHERE
landuse='vineyard';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Sonstige Landwirtschaftsfläche' as "lu_type", 46 as "lu_nr"  FROM planet_osm_polygon WHERE
landuse='farmyard' OR 
landuse='greenhouse_horticulture' OR 
landuse='plant_nursery' OR 
historic='farm' OR 
building='barn' OR 
building='conservatory' OR 
building='cowshed' OR 
building='farm_auxiliary' OR 
building='greenhouse' OR 
building='slurry_tank' OR 
building='stable' OR 
building='sty';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Laubholz / Nadelholz / Mischholz / Gehölz' as "lu_type", 50 as "lu_nr"  FROM planet_osm_polygon WHERE
"natural"='wood' OR 
landuse='forest' OR 
"natural"='scrub';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Heide' as "lu_type", 60 as "lu_nr"  FROM planet_osm_polygon WHERE
"natural"='heath';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Moor' as "lu_type", 61 as "lu_nr"  FROM planet_osm_polygon WHERE
"natural"='moor';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Sumpf' as "lu_type", 62 as "lu_nr"  FROM planet_osm_polygon WHERE
"natural"='wetland' OR 
"natural"='mud';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Unland, vegetationslose Fläche' as "lu_type", 63 as "lu_nr"  FROM planet_osm_polygon WHERE
"natural"='bare_rock' OR 
"natural"='scree' OR 
"natural"='shingle' OR 
"natural"='sand' OR 
"natural"='glacier' OR 
"natural"='beach' OR 
"natural"='cliff' OR 
"natural"='dune' OR 
"natural"='rock' OR 
"natural"='stone' OR 
"natural"='sinkhole' OR 
tags -> 'geological'='moraine' OR 
tags -> 'geological'='outcrop' OR 
tags -> 'geological'='volcanic_vent' OR 
tags -> 'geological'='volcanic_lava_field' OR 
landuse='salt_pond' OR 
man_made='clearcut';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Fließgewässer / Stehendes Gewässer' as "lu_type", 70 as "lu_nr"  FROM planet_osm_polygon WHERE
"natural"='water' OR 
"natural"='spring' OR 
"natural"='hot_spring' OR 
tags -> 'emergency'='water_tank' OR 
landuse='basin' OR 
landuse='reservoir' OR 
water='river' OR 
water='oxbow' OR 
water='canal' OR 
water='ditch' OR 
water='fish_pass' OR 
water='lake' OR 
water='reservoir' OR 
water='pond' OR 
water='basin' OR 
water='stream_pool' OR 
water='reflecting_pool' OR 
water='moat' OR 
water='wastewater' OR 
waterway='riverbank';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Hafenbecken' as "lu_type", 72 as "lu_nr"  FROM planet_osm_polygon WHERE
water='lock' OR 
waterway='dock' OR 
waterway='boatyard' OR 
amenity='boat_rental' OR 
amenity='boat_sharing' OR 
leisure='marina' OR 
leisure='slipway';

INSERT INTO osm_landuse_monitor 
SELECT *, 'Meer, Bodden' as "lu_type", 73 as "lu_nr"  FROM planet_osm_polygon WHERE
"natural"='bay' OR 
"natural"='strait' OR 
"natural"='reef' OR 
water='lagoon';



--Daten exakt auf AOI Dresden beschneiden

CREATE TABLE osm_landuse_monitor_aoi_dresden AS 
SELECT osm.*, ST_Intersection(aoi.geometry, ST_Transform(osm.way, 4326)) AS "way2"
FROM  osm_landuse_monitor osm, aoi_dresden aoi 
WHERE ST_Intersects(aoi.geometry, ST_Transform(osm.way, 4326));


--neue Geometriespalte aufbereiten

ALTER TABLE osm_landuse_monitor_aoi_dresden
DROP COLUMN way;

ALTER TABLE osm_landuse_monitor_aoi_dresden
RENAME COLUMN way2 TO way;

--Geometrien je LU-Klasse (GROUP BY) vereinigen, um je LU-Klasse Überlappungen zu entfernen
--da neue Geometrien gebildet werden, auch neue UUID vergeben

CREATE TABLE osm_landuse_monitor_aoi_dresden_union AS
SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "id", 
lu_nr, lu_type, ST_Union(a.way) AS "geometry"
FROM osm_landuse_monitor_aoi_dresden a
GROUP BY lu_nr, lu_type;


-- Restpolygon = AOI Dresden hinzufuegen, mit lu_nr = 0. Bedeutet, es ist die unterste Schicht beim Verschneiden
--HINWEIS: nun CRS EPSG-Code 4326 anstelle vorher 3857 (wurde zu spaet bemerkt)

INSERT INTO osm_landuse_monitor_aoi_dresden_union
SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "id", 
0 AS lu_nr, 'outer' AS lu_type, a.geometry AS geometry FROM aoi_dresden a;


--nun die Function Clip_by_Hierarchie ausfuehren. Entsprechende Tabellen fuer Input setzen
--siehe naechstes Skript


--nach der FUNCTION Clip_by_Hierarchie:












--Visualisieren und Bereinigen einer "non-noded intersection" - topologischer Fehler
-- bei Analyse der Overlaps in finaler Variante IOER-Monitor aufgefallen
-- DB Tabelle: osm_landuse_monitor_aoi_dresden_union_hierarchy2

--Tabellen anlegen und mit Koordinaten aus Fehlerreport fuellen
-- dadurch den Fehler in QGIS visualisierbar machen

CREATE TABLE topology_error_lines AS
SELECT 1 AS "id", ST_GeomFromText('LINESTRING (13.9428 50.9625, 13.9427 50.9624)', 4326) AS "geometry"
UNION
SELECT 2 AS "id", ST_GeomFromText('LINESTRING (13.9427 50.9624, 13.9428 50.9625)', 4326) AS "geometry";

CREATE TABLE topology_error_points AS
SELECT 1 AS "id", ST_GeomFromText('POINT (13.942738429241809 50.962451907809488)', 4326) AS "geometry",
	'ERROR:  lwgeom_intersection: GEOS Error: TopologyException: found non-noded intersection between LINESTRING (13.9428 50.9625, 13.9427 50.9624) and LINESTRING (13.9427 50.9624, 13.9428 50.9625) at 13.942738429241809 50.962451907809488 SQL state: XX000' AS "text";

--zunaechst neue Tabelle anlegen, um dort topologischen Fehler bereinigen zu koennen
CREATE TABLE osm_landuse_monitor_aoi_dresden_union_hierarchy2_error AS
SELECT * FROM osm_landuse_monitor_aoi_dresden_union_hierarchy2;

-- das problematische Polygon am Rand der AOI entfernen
DELETE FROM osm_landuse_monitor_aoi_dresden_union_hierarchy2_error WHERE id='44c7344e-7575-d0f9-1da0-754898fec309';

-- war nicht zielfuehrend, da nun das gesamte Restpolygon in dem Datensatz entfernt wurde (Multipolygon)
--bessere alternative: ein Snapping auf die Umrisslinie der AOI Dresden durchfuehren (Edge-Matching)

CREATE TABLE osm_landuse_monitor_aoi_dresden_union_hierarchy2_snap AS
SELECT a.id AS "id",
	a.lu_nr AS "lu_nr",
	a.lu_type AS "lu_type",
	ST_MakeValid(ST_Snap(a.geometry, b.geometry, 0.000002)) AS "geometry"
FROM
	(SELECT * FROM osm_landuse_monitor_aoi_dresden_union_hierarchy2) AS a,
	(SELECT * FROM aoi_dresden) AS b;

--immer noch nicht zufriedenstellend geloest. Da aufgrund fehlender Zwischenpunkte bei laengeren Liniensegmenten nicht gesnappt wurde. Oder nur teilweise.

-- neuer Ansatz: eine "negative" AOI Dresden Geometrie (mit AOI selbst als Loch) sowie ein Puffer der AOI von dem Datensatz subtrahieren..
-- dadurch soll entlang der aeusseren Kante des Datensatzes eine Bereinigung stattfinden. Es wird circa 16cm (0.000002°) Pufferbereich ueberall weggenommen

CREATE TABLE aoi_dresden_negative AS
SELECT 1 AS "id", ST_Buffer(ST_ExteriorRing(a.geometry), 0.000002) AS "geometry" FROM aoi_dresden a
UNION
SELECT 2 AS "id", ST_Difference(ST_GeomFromText('POLYGON ((13.4 50.9, 14.07 50.9, 14.07 51.3, 13.4 51.3, 13.4 50.9))', 4326), b.geometry) AS "geometry"
FROM aoi_dresden b;

DROP TABLE IF EXISTS osm_landuse_monitor_aoi_dresden_union_hierarchy2_edge_aoi;
CREATE TABLE osm_landuse_monitor_aoi_dresden_union_hierarchy2_edge_aoi AS
SELECT a.id AS "id",
	a.lu_nr AS "lu_nr",
	a.lu_type AS "lu_type",
	ST_MakeValid(ST_Difference(a.geometry, b.geometry)) AS "geometry"	
FROM osm_landuse_monitor_aoi_dresden_union_hierarchy2 a,
	(SELECT ST_Union(c.geometry) AS "geometry" FROM aoi_dresden_negative c) AS b;
	
--da das Restpolygon (lu_nr=0) nun zu einer GeometryCollection wurde, dieses auf flaechenhafte Geometrien reduzieren

UPDATE osm_landuse_monitor_aoi_dresden_union_hierarchy2_edge_aoi dest 
SET geometry = ST_CollectionExtract(src.geometry, 3)
FROM osm_landuse_monitor_aoi_dresden_union_hierarchy2_edge_aoi src
WHERE dest.lu_nr = 0 AND src.lu_nr = 0;

--damit wurden die topologischen Probleme dort behoben. Es kann die Analyse der Ueberlappungen fuer die finale Version IOER-Monitor nun erfolgreich durchlaufen 
