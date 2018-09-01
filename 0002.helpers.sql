CREATE FUNCTION "classify"."get_hash_string"(key TEXT, field TEXT) RETURNS TEXT AS $$
	SELECT NULLIF("value_string", '')
	  FROM "classify"."unclassified"
	 WHERE "_key" = key
	   AND "type" = 'hash'
	   AND "unique_string" = field;
$$ LANGUAGE SQL STABLE STRICT PARALLEL SAFE;

CREATE FUNCTION "classify"."get_hash_int"(key TEXT, field TEXT) RETURNS BIGINT AS $$
	SELECT NULLIF("classify"."get_hash_string"(key, field), '0')::BIGINT;
$$ LANGUAGE SQL STABLE STRICT PARALLEL SAFE;

CREATE FUNCTION "classify"."get_hash_timestamp"(key TEXT, field TEXT) RETURNS TIMESTAMPTZ AS $$
	SELECT TO_TIMESTAMP("classify"."get_hash_int"(key, field)::NUMERIC / 1000);
$$ LANGUAGE SQL STABLE STRICT PARALLEL SAFE;

CREATE DOMAIN "classify".COVER_POSITION AS NUMERIC[2]
	NOT NULL DEFAULT '{50,50}'
	CHECK (CARDINALITY(VALUE) = 2
		AND VALUE[1] IS NOT NULL
		AND VALUE[2] IS NOT NULL
		AND VALUE[1] BETWEEN 0 AND 100
		AND VALUE[2] BETWEEN 0 AND 100);

CREATE FUNCTION "classify"."get_hash_position"(key TEXT, field TEXT) RETURNS "classify".COVER_POSITION AS $$
	SELECT ARRAY[COALESCE(pos[1]::NUMERIC, 50), COALESCE(pos[2]::NUMERIC, 50)]::"classify".COVER_POSITION
	  FROM REGEXP_MATCH("classify"."get_hash_string"(key, field), '^(.*)% (.*)%$') pos;
$$ LANGUAGE SQL STABLE STRICT PARALLEL SAFE;

CREATE FUNCTION "classify"."get_hash_boolean"(key TEXT, field TEXT) RETURNS BOOLEAN AS $$
	SELECT CASE WHEN val = '0' THEN FALSE
	            WHEN val = '1' THEN TRUE
	            ELSE NULL END
	  FROM "classify"."get_hash_string"(key, field) val;
$$ LANGUAGE SQL STABLE STRICT PARALLEL SAFE;

CREATE FUNCTION "classify"."get_hash_date"(key TEXT, field TEXT) RETURNS DATE AS $$
BEGIN
	RETURN "classify"."get_hash_string"(key, field)::DATE;
EXCEPTION WHEN OTHERS THEN
	RETURN NULL;
END;
$$ LANGUAGE PLPGSQL STABLE STRICT PARALLEL SAFE;
