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

export CPPFLAGS="${CPPFLAGS} -DSQLITE_ENABLE_COLUMN_METADATA=1 \
                             -DSQLITE_ENABLE_UNLOCK_NOTIFY \
                             -DSQLITE_ENABLE_DBSTAT_VTAB=1 \
                             -DSQLITE_ENABLE_FTS3_TOKENIZER=1 \
                             -DSQLITE_SECURE_DELETE \
                             -DSQLITE_MAX_VARIABLE_NUMBER=250000 \
                             -DSQLITE_MAX_EXPR_DEPTH=10000"

./configure --prefix=${PREFIX}   \
            --build=${BUILD}     \
            --host=${HOST}       \
            --enable-threadsafe  \
            --enable-shared=yes  \
            $READLINE            \
            CFLAGS="${CFLAGS} -I${PREFIX}/include" \
            LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
make -j${CPU_COUNT} ${VERBOSE_AT}
make check
make install

rm -rf  ${PREFIX}/share
