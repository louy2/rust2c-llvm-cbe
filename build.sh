#!/bin/sh
set -x

PROJECT_NAME=$(pwd | xargs basename)
OUTPUT_DIR=$(pwd)
OUTPUT_FILE=$OUTPUT_DIR/$PROJECT_NAME

RUSTC_TRIPLE=$(rustup show active-toolchain | cut -f 1 -d " " | sed "s/^[^\-]*-//")
RUSTC_LIB="$(rustc --print sysroot)/lib/rustlib/$RUSTC_TRIPLE/lib"

LLVM_CBE="$(pwd)/llvm-cbe/build/tools/llvm-cbe/llvm-cbe"
CC="$(find $(brew --cellar llvm@11) -name "clang" | grep bin | head -1)"

# Build main with temporary files preserved and emit LLVM-IR
cargo rustc --verbose -- --verbose --codegen save-temps --emit=llvm-ir

cd target/debug/deps

# Remove the unoptimized bc or we'll get duplicate symbols at link time
rm *no-opt*

# Compile LLVM IR to C
find . -name '*.ll' ! -name '*.rcgu.*' | xargs -n 1 $LLVM_CBE

# Compile C to obj
$CC -c *.cbe.c


$CC -L $RUSTC_LIB \
  *.cbe.o \
  $(find $(pwd) -name '*.rcgu.o' | head -1) \
  $(ls | grep '\.rlib$' | sed 's/lib/ \.\/lib/') \
  $(find $RUSTC_LIB -name '*rlib') \
  -L $(rustc --print sysroot)/lib/ \
  -Wl,-dead_strip -nodefaultlibs -lSystem -lresolv -lc -lm \
  -o $OUTPUT_FILE
