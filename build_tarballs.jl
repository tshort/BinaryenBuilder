using BinaryBuilder

# Collection of sources required to build Binaryen
sources = [
    "https://github.com/WebAssembly/binaryen/archive/1.37.36.tar.gz" =>
    "e77520b31e81befe7767f7179243983d678cda6d22cb07110a92aa2ff38831f7",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
ls -l
cd binaryen-1.37.36/
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain
make -j8
make install

if [ $target = "x86_64-w64-mingw32" ]; then
mv $WORKSPACE/destdir/lib/*.dll $WORKSPACE/destdir/bin
cp /opt/x86_64-w64-mingw32/x86_64-w64-mingw32/bin/libwinpthread-1.dll $WORKSPACE/destdir/bin
fi


"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    BinaryProvider.Linux(:i686, :glibc, :blank_abi),
    BinaryProvider.Linux(:x86_64, :glibc, :blank_abi),
    BinaryProvider.Linux(:aarch64, :glibc, :blank_abi),
    BinaryProvider.Linux(:armv7l, :glibc, :eabihf),
    BinaryProvider.Linux(:powerpc64le, :glibc, :blank_abi),
    BinaryProvider.Linux(:i686, :musl, :blank_abi),
    BinaryProvider.Linux(:x86_64, :musl, :blank_abi),
    BinaryProvider.Linux(:aarch64, :musl, :blank_abi),
    BinaryProvider.Linux(:armv7l, :musl, :eabihf)
]

# The products that we will ensure are always built
products(prefix) = [
    ExecutableProduct(prefix, "", :s2wasm),
    ExecutableProduct(prefix, "", :wasm_reduce),
    ExecutableProduct(prefix, "", :wasm_emscripten_finalize),
    ExecutableProduct(prefix, "", :wasm_metadce),
    ExecutableProduct(prefix, "", :wasm_opt),
    ExecutableProduct(prefix, "", :wasm_merge),
    ExecutableProduct(prefix, "", :wasm_dis),
    ExecutableProduct(prefix, "", :wasm_as),
    ExecutableProduct(prefix, "", :wasm2asm),
    ExecutableProduct(prefix, "", :wasm_ctor_eval),
    LibraryProduct(prefix, "libbinaryen", :libbinaryen),
    ExecutableProduct(prefix, "", :wasm_shell),
    ExecutableProduct(prefix, "", :asm2wasm)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, "Binaryen", sources, script, platforms, products, dependencies)

