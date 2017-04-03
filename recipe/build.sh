#!/bin/bash

# Prevent running ldconfig when cross-compiling
if [[ "${BUILD}" != "${HOST}" ]]; then
  echo "#!/usr/bin/env bash" > ldconfig
  chmod +x ldconfig
  export PATH=${PWD}:$PATH
fi

./configure --build=${BUILD} --host=${HOST} \
            --enable-threadsafe \
            --enable-tempstore \
            --enable-shared=yes \
            --disable-tcl \
            --disable-readline \
            --prefix=$PREFIX
make
make check
make install

rm -rf  $PREFIX/share
