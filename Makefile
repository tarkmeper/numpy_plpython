#  Based on the jsonb_contrib makefile

MODULE_big = numpy_plpython$(python_majorversion)
OBJS = numpy_plpython.o $(WIN32RES)
PGFILEDESC = "numpy_plpython - transform between Postgres arrays and Numpy Arrays"

PG_CPPFLAGS = -I$(shell python -c "import numpy; print(numpy.get_include());") -I$(top_srcdir)/src/pl/plpython $(python_includespec) -DPLPYTHON_LIBNAME='"plpython$(python_majorversion)"'
#PG_CPPFLAGS = -I$(top_srcdir)/src/pl/plpython $(python_includespec) -DPLPYTHON_LIBNAME='"plpython$(python_majorversion)"'

EXTENSION = numpy_plpythonu numpy_plpython2u numpy_plpython3u
DATA = numpy_plpythonu--1.0.sql numpy_plpython2u--1.0.sql numpy_plpython3u--1.0.sql

REGRESS = numpy_plpython
REGRESS_PLPYTHON3_MANGLE := $(REGRESS)

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

# We must link libpython explicitly
ifeq ($(PORTNAME), win32)
# ... see silliness in plpython Makefile ...
SHLIB_LINK_INTERNAL += $(sort $(wildcard ../../src/pl/plpython/libpython*.a))
else
rpathdir = $(python_libdir)
SHLIB_LINK += $(python_libspec) $(python_additional_libs)
endif

ifeq ($(python_majorversion),2)
REGRESS_OPTS += --load-extension=plpythonu --load-extension=numpy_plpythonu
endif

include $(top_srcdir)/src/pl/plpython/regress-python3-mangle.mk
