-- UNTESTED
WITH slot_age AS (
	SELECT slot_name, slot_type, active
	, xmin
	, catalog_xmin
	, age(xmin) as xid_age
	, age(catalog_xmin) AS catalog_xid_age
	FROM pg_replication_slots
),
av_max_age AS (
	SELECT setting::numeric AS max_age FROM pg_settings WHERE name = 'autovacuum_freeze_max_age'
),
wrap_pct AS (
	SELECT slot_name, slot_type, active
	, xmin
	, catalog_xmin
	, xid_age
	, catalog_xid_age
	, round(xid_age*100::numeric/max_age, 1) AS av_wrap_pct
	, round(xid_age*100::numeric/2200000000, 1) as shutdown_pct
	, round(catalog_xid_age*100::numeric/max_age, 1) AS av_wrap_pct_catalog
	, round(catalog_xid_age*100::numeric/2200000000, 1) as shutdown_pct_catalog
	FROM slot_age CROSS JOIN av_max_age
)
SELECT * FROM wrap_pct
ORDER BY xid_age DESC
;
