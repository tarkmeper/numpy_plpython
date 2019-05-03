#include "postgres.h"

#include "plpython.h"

#define NPY_NO_DEPRECATED_API NPY_1_7_API_VERSION

#include "fmgr.h"
#include "utils/array.h"
#include "utils/fmgrprotos.h"
#include "utils/numeric.h"
#include "catalog/pg_type.h"
#include "numpy/ndarrayobject.h"


PG_MODULE_MAGIC;

PG_FUNCTION_INFO_V1(numpy_to_plpython);
Datum numpy_to_plpython(PG_FUNCTION_ARGS) {
	PyObject *result;
	ArrayType* arr = PG_GETARG_ARRAYTYPE_P_COPY(0);
	const int nd = ARR_NDIM(arr);
	npy_intp ndims[MAXDIM];

	//not sure if this is required, believe can likely just pass in
	//without this.
	for (int i = 0; i < nd; ++i) {
		ndims[i] = ARR_DIMS(arr)[i];
	}
	result = PyArray_SimpleNewFromData(nd, ndims, NPY_CFLOAT, ARR_DATA_PTR(arr) );
	return PointerGetDatum(result);
}

PG_FUNCTION_INFO_V1(plpython_to_numpy);
Datum plpython_to_numpy(PG_FUNCTION_ARGS) {
	import_array();
	ArrayType* result;
	PyObject   *o = (PyObject *) PG_GETARG_POINTER(0);
        elog(NOTICE, "The object we reiceved has a type of %s", Py_TYPE(o)->tp_name);
        PyArrayObject *obj = (PyArrayObject*)(o);
        elog(NOTICE, "New size is %d", PyArray_SIZE(obj));

	const npy_intp size = PyArray_SIZE(obj);
	Datum* arr = (Datum*)palloc(size * sizeof(Datum));
	float* ptr = (float*)PyArray_DATA(obj);

        for (npy_intp i = 0; i < size; ++i) {
                arr[i] = Float4GetDatum(ptr[i]);
        }

	result = construct_array(arr, size, FLOAT4OID, 4, true, 'i');
        PG_RETURN_ARRAYTYPE_P(result);
}

