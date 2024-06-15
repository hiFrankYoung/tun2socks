ios:
	cargo lipo --release -p leaf-ffi
	cbindgen --config leaf-ffi/cbindgen.toml leaf-ffi/src/lib.rs > target/universal/release/leaf.h

ios-dev:
	cargo lipo -p leaf-ffi
	cbindgen --config leaf-ffi/cbindgen.toml leaf-ffi/src/lib.rs > target/universal/debug/leaf.h

ios-opt:
	cargo lipo --release --targets aarch64-apple-ios --manifest-path leaf-ffi/Cargo.toml --no-default-features --features "default-openssl"
	cbindgen --config leaf-ffi/cbindgen.toml leaf-ffi/src/lib.rs > target/universal/release/leaf.h

lib:
	cargo build -p leaf-ffi --release
	cbindgen --config leaf-ffi/cbindgen.toml leaf-ffi/src/lib.rs > target/release/leaf.h

lib-dev:
	cargo build -p leaf-ffi
	cbindgen --config leaf-ffi/cbindgen.toml leaf-ffi/src/lib.rs > target/debug/leaf.h

local:
	cargo build -p leaf-bin --release

local-dev:
	cargo build -p leaf-bin

mipsel:
	./misc/build_cross.sh mipsel-unknown-linux-musl

mips:
	./misc/build_cross.sh mips-unknown-linux-musl

test:
	cargo test -p leaf -- --nocapture

# Force a re-generation of protobuf files.
proto-gen:
	touch leaf/build.rs
	PROTO_GEN=1 cargo build -p leaf


ios-arm64:
	cargo lipo --release --package tun2socks --targets "aarch64-apple-ios"
	mkdir target/ios-arm64
	cp target/universal/release/libtun2socks.a target/ios-arm64/libtun2socks.a

ios-arm64_x86_64-simulator:
	cargo lipo --release --package tun2socks --targets "aarch64-apple-ios-sim,x86_64-apple-ios"
	mkdir target/ios-arm64_x86_64-simulator
	cp target/universal/release/libtun2socks.a target/ios-arm64_x86_64-simulator/libtun2socks.a

macos-arm64_x86_64:
	cargo lipo --release --package tun2socks --targets "aarch64-apple-darwin,x86_64-apple-darwin"
	mkdir target/macos-arm64_x86_64
	cp target/universal/release/libtun2socks.a target/macos-arm64_x86_64/libtun2socks.a

xcframework: ios-arm64 ios-arm64_x86_64-simulator macos-arm64_x86_64
	xcodebuild -create-xcframework -library target/ios-arm64/libtun2socks.a -library target/ios-arm64_x86_64-simulator/libtun2socks.a -library target/macos-arm64_x86_64/libtun2socks.a -output target/Tun2SocksFramework.xcframework