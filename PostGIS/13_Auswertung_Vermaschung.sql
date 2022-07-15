--Auswertung der Vermaschung


-- in Abhaengigkeit von Likelihood innerhalb der BBox

SELECT a.likelihood, 
COUNT(a.*) AS "Anzahl",
ROUND(SUM(ST_Length(a.geometry))::numeric, 2) AS "Laenge",
(SELECT  string_agg(DISTINCT b.origin, ', ') FROM linien_pool_bbox b WHERE b.likelihood=a.likelihood) AS "origins"
FROM linien_pool_bbox a GROUP BY likelihood ORDER BY likelihood DESC;


--Statistik auf Flaecheninhalte

SELECT
	COUNT (b.*) AS "anzahl",
	ROUND(AVG(b.area)::numeric, 2) AS "area_durchschnitt",
	ROUND(MAX(b.area)::numeric, 2) AS "area_max",
	ROUND(MIN(b.area)::numeric, 2) AS "area_min",
	ROUND(stddev(b.area)::numeric, 2) AS "area_stabw"
FROM   
	(SELECT id,
	 ST_Transform(a.geometry, 3857) AS "geometry",
	 ST_Area(ST_Transform(a.geometry, 3857)) AS "area"
	FROM polygonize_0_0_buffered a 
	WHERE 1=1) AS b;
	
	
	
--zur Laufzeit Auswertung Anzahl Linien und Länge in m ermitteln

SELECT COUNT(*), ROUND(SUM(ST_Length(geometry))::numeric, 2) 
FROM linien_pool_bbox WHERE likelihood >= 0;

