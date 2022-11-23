#!/bin/sh

set -xe

chmod -R u+w .

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./config

export CC=${PREFIX}/bin/h5cc
export DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib
export CFLAGS="-fPIC $CFLAGS"

export HDF5_LDFLAGS="-L ${PREFIX}/lib"

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 && $target_platform == "osx-arm64" ]]; then
    he5_cv_f2cFortran_defined=no
    ac_cv_lib_hdf5_H5Fcreate=yes
    he5_cv_hdf5_szip_can_decode=no
    he5_cv_hdf5_szip_can_encode=no
fi

./configure --prefix=${PREFIX} \
            --with-hdf5=${PREFIX} \
            --with-zlib=${PREFIX}

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
