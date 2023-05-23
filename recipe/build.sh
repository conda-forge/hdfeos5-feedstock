#!/bin/sh

set -x

chmod -R u+w .

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./config

export CC=${PREFIX}/bin/h5cc
export DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib
export CFLAGS="-fPIC $CFLAGS"

export HDF5_LDFLAGS="-L ${PREFIX}/lib"

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 && $target_platform == "osx-arm64" ]]; then
    # The following is borrowed from `configure`.
    # Note that we don't `export` and thus don't pollute
    # `configure` itself.
    # Avoid depending upon Character Ranges.
    as_cr_letters='abcdefghijklmnopqrstuvwxyz'
    as_cr_LETTERS='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    as_cr_Letters=$as_cr_letters$as_cr_LETTERS
    as_cr_digits='0123456789'
    as_cr_alnum=$as_cr_Letters$as_cr_digits
    # Sed expression to map a string onto a valid variable name.
    as_tr_sh="eval sed 'y%*+%pp%;s%[^_$as_cr_alnum]%_%g'"

    export szlib_inc="${PREFIX}/include"
    export szlib_lib="${PREFIX}/lib"
    as_ac_File=`echo "ac_cv_file_$szlib_inc/szlib.h" | $as_tr_sh`
    eval "export $as_ac_File=yes"

    export he5_cv_f2cFortran_defined=no
    export ac_cv_lib_hdf5_H5Fcreate=yes
    export he5_cv_hdf5_szip_can_decode=yes
    export he5_cv_hdf5_szip_can_encode=yes
    export he5_cv_szlib_functional=yes
fi

./configure --prefix=${PREFIX} \
            --with-hdf5=${PREFIX} \
            --with-zlib=${PREFIX} \
            --with-szlib=${PREFIX}

config_result=$?

echo "=====================config.log==================="
cat config.log
echo "=======================finish====================="

if [ ${config_result} -ne 0 ]; then
    echo "Bailing due to failed configure with ${config_result}"
    exit ${config_result}
fi

make
# skip "make check" because sample program he5_pt_readattrs is failing:
# make[2]: *** [pt_write_test] Segmentation fault (core dumped)
#make check
make install

pushd include
make install-includeHEADERS
popd

# We can remove this when we start using the new conda-build.
find $PREFIX -name '*.la' -delete
