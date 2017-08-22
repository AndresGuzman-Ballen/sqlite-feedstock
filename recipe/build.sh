#!/bin/bash

export LDFLAGS="$LDFLAGS $(pkg-config --libs ncurses)"
export CPPFLAGS="$CPPFLAGS $(pkg-config --cflags-only-I ncurses)"
export CFLAGS="$CFLAGS $(pkg-config --cflags-only-I ncurses)"

if [ $(uname -m) == ppc64le ]; then
    export B="--build=ppc64le-linux"
fi

./configure SQLITE_ENABLE_RTREE=1 \
            $B --enable-threadsafe \
            --enable-json1 \

# Prevent running ldconfig when cross-compiling
if [[ "${BUILD}" != "${HOST}" ]]; then
  echo "#!/usr/bin/env bash" > ldconfig
  chmod +x ldconfig
  export PATH=${PWD}:$PATH
fi

[[ "$GPL_ok" = 1 ]] && READLINE="--enable-readline --disable-editline" || READLINE="--disable-readline --enable-editline"

./configure --prefix=$PREFIX     \
            --build=${BUILD}     \
            --host=${HOST}       \
            --enable-threadsafe  \
            --enable-shared=yes  \
            $READLINE            \
            CFLAGS="${CFLAGS} -I${PREFIX}/include" \
            LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
make
make check
make install
