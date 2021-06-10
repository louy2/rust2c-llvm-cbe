# Rust2C via LLVM CBE

Trying to compile Rust code to C code through [LLVM CBE](https://github.com/JuliaComputingOSS/llvm-cbe).

Rust code is taken from [Getting Started with ECS using Planck ECS](https://jojolepro.com/blog/2021-06-01_getting_started_with_ecs/).

## Building LLVM CBE on macOS

Install LLVM 11 and cmake with Homebrew

    brew install llvm@11 cmake


Pull in the LLVM CBE repo

    git submodule init
    git submodule update


Configure and build

```
cd llvm-cbe
mkdir build && cd build
LLVM_DIR="$(brew --prefix)/opt/llvm@11/lib/cmake/llvm" cmake -S ..
make llvm-cbe
```

The result will be at `rust2c-llvm-cbe/llvm-cbe/build/tools/llvm-cbe/llvm-cbe`.

## Emit LLVM IR with cargo

The last stable version using LLVM 11 is 1.50.0 so we change to that with rustup. In project root run:

    rustup toolchain install 1.50.0
    rustup override set 1.50.0

There is a [bug](https://github.com/rust-lang/rust/issues/84970) so we disable incremental build

    mkdir -p .cargo
    echo 'build.incremental = false' >> .cargo/config.toml

Finally we emit LLVM IR:

    cargo rustc -- --emit=llvm-ir

The results will be in `rust2c-llvm-cbe/target/debug/deps` with suffix `.ll`.

## Build binary via llvm-cbe

    sh build.sh

## More

Cross build the [Rust part of pyca/cryptography](https://github.com/pyca/cryptography/tree/main/src/rust) to [m86k](https://wiki.debian.org/M68k/QemuSystemM68k).

## References

* [Manually linking Rust binaries to support out-of-tree LLVM passes](https://medium.com/@squanderingtime/manually-linking-rust-binaries-to-support-out-of-tree-llvm-passes-8776b1d037a4)