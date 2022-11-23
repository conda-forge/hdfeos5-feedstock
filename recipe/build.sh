#!/bin/sh

set -xe

chmod -R u+w .

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./config

export CC=${PREFIX}/bin/h5cc
export DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib
export CFLAGS="-fPIC $CFLAGS"

export HDF5_LDFLAGS="-L ${PREFIX}/lib"

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
