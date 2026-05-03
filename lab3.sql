INSTALL spatial;
LOAD spatial;

INSTALL httpfs;
LOAD httpfs;

INSTALL overture FROM community;
LOAD overture;

CREATE TABLE geo_data AS
SELECT *
FROM ST_Read('map.json');

SELECT
MIN(ST_XMin(geom)) AS xmin,
MAX(ST_XMax(geom)) AS xmax,
MIN(ST_YMin(geom)) AS ymin,
MAX(ST_YMax(geom)) AS ymax
FROM geo_data;

SET s3_region = 'us-west-2';

CREATE TABLE overture_buildings_polygons AS
SELECT *
FROM read_parquet(
's3://overturemaps-us-west-2/release/2026-04-15.0/theme=buildings/type=building/*.parquet',
hive_partitioning = true
)
WHERE bbox.xmin <= 50.8848041
AND bbox.xmax >= 50.8439571
AND bbox.ymin <= 53.2998886
AND bbox.ymax >= 53.2567737;

ALTER TABLE overture_buildings_polygons
ADD COLUMN source_type TEXT;

UPDATE overture_buildings_polygons ob
SET source_type = 'my'
WHERE EXISTS (
    SELECT 1
    FROM geo_data gd
    WHERE gd.user = 'Ксения Дубова'
        AND ST_Contains(
            gd.geom,
            ST_Centroid(ob.geometry)
        )
        AND ST_Area(gd.geom) < 0.000001
);

UPDATE overture_buildings_polygons
SET source_type = CASE
WHEN sources::VARCHAR ILIKE '%OpenStreetMap%' THEN 'osm'
WHEN sources::VARCHAR ILIKE '%Microsoft%'
OR sources::VARCHAR ILIKE '%Google%'
OR sources::VARCHAR ILIKE '%ML%' THEN 'ml'
ELSE 'unknown'
END
WHERE source_type IS NULL;

SET geometry_always_xy = true;

COPY (
SELECT
geometry,
source_type
FROM overture_buildings_polygons
)
TO 'overture.geojson'
WITH (FORMAT GDAL, DRIVER 'GeoJSON');

-- после файл overture.geojson был перенесен в клиента для удобства