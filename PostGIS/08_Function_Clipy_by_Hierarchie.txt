--Function zum Verschneiden aller LU-Klassen gemaess der Hierarchie aus Attribut lu_nr aufsteigend
--aktuell ohne funktionierende Uebergabe eines Tabellennamens (lies sich ueber regclass nicht realisieren. Geht wohl ueber SQL Abfragen als Zeichenkette zusammengesetzt)
--Eingabe-Tabelle muss im Code an mehreren Stellen gesetzt werden
-- am Schluss Geometrien aus Tabelle temp_01 in gewuenschte Ausgabe-Tabelle kopieren


CREATE OR REPLACE FUNCTION public.clip_by_hierarchy (
   tablename_input VARCHAR
) 
RETURNS TABLE ( 
	id UUID,
	lu_nr INTEGER,
	lu_type VARCHAR,
	geometry GEOMETRY
) 

AS $$
DECLARE 
-- variable declaration
	cur_row record;
	cur_row_2 record;
	count_loop INTEGER := 0;
	last_lu_nr INTEGER := -1;
	
	cnt_total INTEGER := 0;
	
	cnt_multipolygon INTEGER := 0;
	cnt_geom_collection INTEGER := 0;
	
	cnt_simple INTEGER := 0;
	cnt_valide INTEGER := 0;
	
BEGIN
-- body

	RAISE NOTICE 'Function has been started: %', TIMEOFDAY();
	-- CREATE TEMPORARY TABLE:
	RAISE NOTICE 'temp_1';
	DROP TABLE IF EXISTS temp_01;
	CREATE TABLE temp_01 (	id UUID,
		lu_nr INTEGER,
		lu_type VARCHAR,
		geometry GEOMETRY);
		
	RAISE NOTICE 'temp_diff';
	DROP TABLE IF EXISTS temp_diff;
	CREATE TABLE temp_diff (	id UUID,
		lu_nr INTEGER,
		lu_type VARCHAR,
		geometry GEOMETRY);	

	RAISE NOTICE 'LOOP';	
	
	FOR cur_row IN(
            SELECT * 
            FROM public.osm_landuse_monitor_aoi_dresden_union ab
			WHERE ab.lu_nr > 0
			ORDER BY lu_nr ASC
    ) LOOP  
			-- LOOP:	
			
			RAISE NOTICE '---------------------';
			RAISE NOTICE 'new iteration: %', TIMEOFDAY();
			RAISE NOTICE 'iteration number: %', count_loop;
			RAISE NOTICE 'ID: %, lu_nr: %, lu_type: %', cur_row.id, cur_row.lu_nr, cur_row.lu_type;
			IF count_loop = 0 THEN
				INSERT INTO temp_01 SELECT * FROM public.osm_landuse_monitor_aoi_dresden_union ac WHERE ac.lu_nr = 0; 
			END IF;
			
			DELETE FROM temp_diff;
			INSERT INTO temp_diff
			SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "id", 
				d.lu_nr,
				d.lu_type,
				ST_Difference(d.geometry, ST_MakeValid(ST_SnapToGrid(b.geometry, 0.000001))) AS "geometry"

			FROM (SELECT * FROM temp_01) AS d,
				(SELECT * FROM public.osm_landuse_monitor_aoi_dresden_union d1 WHERE d1.lu_nr = cur_row.lu_nr) AS b
			UNION
			SELECT d2.id, d2.lu_nr, d2.lu_type, ST_MakeValid(ST_SnapToGrid(d2.geometry, 0.000001)) AS "geometry" FROM public.osm_landuse_monitor_aoi_dresden_union d2 WHERE d2.lu_nr = cur_row.lu_nr;
			
			-- Qualitaetskontrolle	
			SELECT COUNT(a.*) INTO cnt_total FROM temp_diff a;
			SELECT COUNT(a.*) INTO cnt_multipolygon FROM temp_diff a WHERE ST_GeometryType(a.geometry) = 'ST_MultiPolygon';
			SELECT COUNT(a.*) INTO cnt_geom_collection FROM temp_diff a WHERE ST_GeometryType(a.geometry) = 'ST_GeometryCollection';
			RAISE NOTICE 'Total number: % (ST_Multipolygon: %, ST_GeometryCollection: %)', cnt_total, cnt_multipolygon, cnt_geom_collection;
			
			IF cnt_geom_collection = 0 THEN
				 SELECT COUNT(a.*) INTO cnt_simple FROM temp_diff a WHERE ST_IsSimple(a.geometry) = 'true';			
				 SELECT COUNT(a.*) INTO cnt_valide FROM temp_diff a WHERE ST_IsValid(a.geometry) = 'true';	
				 RAISE NOTICE '(ST_IsSimple: %, ST_IsValid: %)', cnt_simple, cnt_valide;
			END IF;

			--Datenbereinigung:
			-- wenn ST_GeometryCollection, dann ST_LineString und ST_Point entfernen und zu ST_Multipolygon umwandeln
			IF cnt_geom_collection > 0 THEN
				-- konvertiere ST_GeometryCollection zu ST_Multipolygon (3=Polygon)
				RAISE NOTICE 'UPDATE SET';
				UPDATE temp_diff ad SET geometry = ST_CollectionExtract(src.geometry, 3) 
				FROM temp_diff src
				WHERE ad.id IN (SELECT a.id FROM temp_diff a WHERE ST_GeometryType(a.geometry) = 'ST_GeometryCollection')
				AND ad.id=src.id;
				RAISE NOTICE 'End - UPDATE SET';
			END IF;	
			
			-- Daten updaten
			RAISE NOTICE 'Daten updaten...';
			DELETE FROM temp_01;
			INSERT INTO temp_01 SELECT * FROM temp_diff;		
		
			last_lu_nr = cur_row.lu_nr;
			-- count
			count_loop = count_loop + 1;
			
			RAISE NOTICE '%', TIMEOFDAY();

            RETURN NEXT;
	END LOOP;

RETURN QUERY (SELECT * FROM temp_01);
END; 
$$ 
LANGUAGE plpgsql;

SELECT public.clip_by_hierarchy('dummy');






