CREATE TABLE test_t (
	x real[]
);

INSERT INTO test_t (SELECT array_agg(i) FROM generate_series(1,2000) as i );

CREATE FUNCTION np (a real[]) RETURNS text
    TRANSFORM FOR TYPE real[]
    AS $$  return "testing %s %s" % (type(a), len(a)) $$ LANGUAGE plpythonu;

CREATE FUNCTION base (a real[]) RETURNS text
    AS $$  return "testing %s %s" % (type(a), len(a)) $$ LANGUAGE plpythonu;


CREATE FUNCTION np2 (text) RETURNS real[]
    TRANSFORM FOR TYPE real[]
    AS $$
import numpy as np
return np.ones(2000, dtype='float32')
$$ LANGUAGE plpythonu;

CREATE FUNCTION base2 (text) RETURNS real[]
    AS $$
import numpy as np
return np.ones(2000, dtype='float32')
$$ LANGUAGE plpythonu;

--prime this so that numpy is in memory
SELECT array_length(base2('asd'), 1) as arr;
SELECT array_length(np2('asd'), 1) as arr;

SELECT base(x) from test_t;
SELECT np(x) from test_t;


\timing
SELECT array_length(base2('asd'), 1) as arr;
SELECT array_length(np2('asd'), 1) as arr;
SELECT array_length(np2('asd'), 1) as arr;
SELECT array_length(base2('asd'), 1) as arr;

SELECT base(x) from test_t;
SELECT np(x) from test_t;
SELECT np(x) from test_t;
SELECT base(x) from test_t;

