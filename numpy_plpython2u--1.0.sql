-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION jsonb_plpython2u" to load this file. \quit

CREATE FUNCTION numpy_to_plpython2(val internal) RETURNS internal LANGUAGE C STRICT IMMUTABLE
AS 'MODULE_PATHNAME', 'numpy_to_plpython';

CREATE FUNCTION plpython2_to_numpy(val internal) RETURNS real LANGUAGE C STRICT IMMUTABLE
AS 'MODULE_PATHNAME', 'plpython_to_numpy';

CREATE TRANSFORM FOR real LANGUAGE plpython2u (
    FROM SQL WITH FUNCTION numpy_to_plpython2(internal),
    TO SQL WITH FUNCTION plpython2_to_numpy(internal)
);

--COMMENT ON TRANSFORM FOR real[] LANGUAGE plpython2u IS 'transform between numpy and Python';
