CREATE OR REPLACE FUNCTION "classify"."get_hash_string"(key TEXT, field TEXT) RETURNS TEXT AS $$
	SELECT NULLIF("value_string", '')
	  FROM "classify"."unclassified"
	 WHERE "_key" = key
	   AND "type" = 'hash'
	   AND "unique_string" = field;
$$ LANGUAGE SQL STABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION "classify"."get_hash_timestamp"(key TEXT, field TEXT) RETURNS TIMESTAMPTZ AS $$
	SELECT TO_TIMESTAMP(NULLIF("classify"."get_hash_string"(key, field), '0')::NUMERIC / 1000);
$$ LANGUAGE SQL STABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION "classify"."get_hash_boolean"(key TEXT, field TEXT) RETURNS BOOLEAN AS $$
	SELECT CASE WHEN val = '0' THEN FALSE
	            WHEN val = '1' THEN TRUE
	            ELSE NULL END
	  FROM "classify"."get_hash_string"(key, field) val;
$$ LANGUAGE SQL STABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION "classify"."get_hash_date"(key TEXT, field TEXT) RETURNS DATE AS $$
BEGIN
	RETURN "classify"."get_hash_string"(key, field)::DATE;
EXCEPTION WHEN OTHERS THEN
	RETURN NULL;
END;
$$ LANGUAGE PLPGSQL STABLE STRICT PARALLEL SAFE;
