--Auswertung Ground-Truth

--zuerst Tabellen importieren

--Auswahl an erfassten Daten in neue Tabelle kopieren:
DROP TABLE IF EXISTS gt_landuse_sel;
CREATE TABLE gt_landuse_sel AS
SELECT * FROM gt_landuse_20210912
WHERE barriere IS NOT NULL;


--Dort nun alle geometrischen Duplikate loeschen (jeweils das Feature mit kleinerer fid erhalten)
DELETE FROM gt_landuse_sel WHERE fid IN (
SELECT GREATEST(a.fid, b.fid) AS "fid"
FROM gt_landuse_sel a, gt_landuse_sel b 
WHERE ST_Equals(a.geometry, b.geometry) AND a.fid != b.fid 
AND a.barriere IS NOT NULL AND b.barriere IS NOT NULL);


--die noch in beide Richtungen enthaltenen LU-Wechsel fuer besseres Analysen auf eine Reihenfolge aendern

DROP TABLE IF EXISTS gt_landuse_sel_2;
CREATE TABLE gt_landuse_sel_2 AS
SELECT *, 
GREATEST(a_lu_nr, b_lu_nr) AS "a2_lu_nr", 
LEAST(a_lu_nr, b_lu_nr) AS "b2_lu_nr",
(CASE WHEN a_lu_nr > b_lu_nr THEN a_lu_type ELSE b_lu_type END) AS "a2_lu_type",
(CASE WHEN a_lu_nr < b_lu_nr THEN a_lu_type ELSE b_lu_type END) AS "b2_lu_type"
FROM gt_landuse_sel;


--pro LU-Wechsel nach Anzahl an Objekten auswerten und ausgeben

SELECT b.*, 
("anz_barriere_yes"::float / "anzahl_gueltige") AS "anteil_yes"
FROM (
	SELECT 
		a.a2_lu_nr, 
		a.b2_lu_nr,
		COUNT(a.*) AS "anzahl", 
		(COUNT(a.*) - (COUNT (a.*) FILTER (WHERE a.barriere='nodata'))) AS "anzahl_gueltige",
		COUNT (a.*) FILTER (WHERE a.barriere='yes') AS "anz_barriere_yes",
		COUNT (a.*) FILTER (WHERE a.barriere='no') AS "anz_barriere_no"
	FROM gt_landuse_sel_2 a
	WHERE a.barriere IS NOT NULL
	GROUP BY a.a2_lu_nr, a.b2_lu_nr) AS b 
WHERE "anzahl_gueltige" > 0
ORDER BY "anteil_yes" DESC, "anzahl" DESC;


--noch ein Attribut zur Ground-Truth Area anhaengen, fuer Analysen getrennt nach Großer Garten und Neustadt
ALTER TABLE gt_landuse_sel_2
ADD COLUMN region VARCHAR;

--und mit den beiden Gebieten intersecten. Jeweils den Namen "Großer Garten", "Neustadt" anhaengen
UPDATE gt_landuse_sel_2 dest SET region = (SELECT name FROM aoi_dresden_gt gt WHERE ST_Intersects(gt.geometry, src.geometry))
FROM gt_landuse_sel_2 src
WHERE dest.id=src.id;

--Auswertung pro LU-Wechsel in neue Tabelle schreiben

CREATE TABLE lu_change_likelihood AS
SELECT b.*, 
("anz_barriere_yes"::float / "anzahl_gueltige") AS "anteil_yes_anz",
("laenge_barriere_yes"::float / "laenge_gueltige") AS "anteil_yes_laenge"
FROM (
	SELECT 
		a.a2_lu_nr, 
		a.a2_lu_type,
		a.b2_lu_nr,
		a.b2_lu_type,
		COUNT(a.*) AS "anzahl", 
		(COUNT(a.*) - (COUNT (a.*) FILTER (WHERE a.barriere='nodata'))) AS "anzahl_gueltige",
		COUNT (a.*) FILTER (WHERE a.barriere='yes') AS "anz_barriere_yes",
		COUNT (a.*) FILTER (WHERE a.barriere='no') AS "anz_barriere_no",
		SUM(ST_Length(ST_Transform(a.geometry, 3857))) FILTER (WHERE a.barriere='yes') AS "laenge_barriere_yes",
		SUM(ST_Length(ST_Transform(a.geometry, 3857))) FILTER (WHERE a.barriere!='nodata') AS "laenge_gueltige"	
	FROM gt_landuse_sel_2 a
	WHERE a.barriere IS NOT NULL
	GROUP BY a.a2_lu_nr, a.b2_lu_nr, a.a2_lu_type, a.b2_lu_type) AS b 
WHERE "anzahl_gueltige" > 0
ORDER BY "anteil_yes_laenge" DESC, "anzahl" DESC;

-----------------------------------------

-- Wege / trails mit ihren Barriere-Wahrscheinlichkeiten berechnen

-----------------------------------------

--noch ein Attribut zur Ground-Truth Area anhaengen, fuer Analysen getrennt nach Großer Garten und Neustadt
ALTER TABLE gt_trail_20210912
ADD COLUMN region VARCHAR;

--und mit den beiden Gebieten intersecten. Jeweils den Namen "Großer Garten", "Neustadt" anhaengen
UPDATE gt_trail_20210912 dest SET region = (SELECT name FROM aoi_dresden_gt gt WHERE ST_Intersects(gt.geometry, src.geometry))
FROM gt_trail_20210912 src
WHERE dest.osm_id=src.osm_id;

--wieder das Attribut highway anspielen (dies war fuer den Ground-Truth entfernt worden)

ALTER TABLE gt_trail_20210912
ADD COLUMN highway VARCHAR;

UPDATE gt_trail_20210912 dest SET highway = src.highway
FROM osm_trail src
WHERE dest.osm_id=src.osm_id;

-- die Barrierenwahrscheinlichkeit nach highway berechnen (Wegetypen)

CREATE TABLE trail_likelihood AS
SELECT b.*, 
("anz_barriere_yes"::float / "anzahl_gueltige") AS "anteil_yes_anz",
("laenge_barriere_yes"::float / "laenge_gueltige") AS "anteil_yes_laenge"
FROM (
	SELECT 
		a.highway, 
		COUNT(a.*) AS "anzahl", 
		(COUNT(a.*) - (COUNT (a.*) FILTER (WHERE a.barriere='nodata'))) AS "anzahl_gueltige",
		COUNT (a.*) FILTER (WHERE a.barriere='yes') AS "anz_barriere_yes",
		COUNT (a.*) FILTER (WHERE a.barriere='no') AS "anz_barriere_no",
		SUM(ST_Length(ST_Transform(a.geometry, 3857))) FILTER (WHERE a.barriere='yes') AS "laenge_barriere_yes",
		SUM(ST_Length(ST_Transform(a.geometry, 3857))) FILTER (WHERE a.barriere!='nodata') AS "laenge_gueltige"	
	FROM gt_trail_20210912 a
	WHERE a.barriere IS NOT NULL
	GROUP BY a.highway) AS b 
WHERE "anzahl_gueltige" > 0
ORDER BY "anteil_yes_laenge" DESC, "anzahl" DESC;

--Quantitative Analyse pro Gebiete

SELECT COUNT(*) AS "Anzahl", SUM(ST_Length(geometry)) AS "Gesamtlaenge" 
FROM gt_landuse_sel_2 WHERE barriere IS NOT NULL

SELECT region, COUNT(*) AS "Anzahl", SUM(ST_Length(geometry)) AS "Gesamtlaenge" 
FROM gt_landuse_sel_2 WHERE barriere IS NOT NULL GROUP BY region;

--Kreuz-Diagramm (seaborn Clustermap) 

--eine VIEW fuer die Clustermap nach Anzahl erstellen
CREATE VIEW view_for_clustermap_by_number AS
SELECT a2_lu_nr, b2_lu_nr, COUNT(*) AS "Anzahl" FROM gt_landuse_sel_2 GROUP BY a2_lu_nr, b2_lu_nr;



--Tabelle fuer Anlage 

SELECT a2_lu_nr, b2_lu_nr, anzahl, anzahl_gueltige, anz_barriere_yes, anteil_yes_laenge 
FROM lu_change_likelihood ORDER BY "anteil_yes_laenge";

