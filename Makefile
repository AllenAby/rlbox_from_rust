RLBOX_ROOT=../rlbox_wasm2c_sandbox

#RLBOX headers
RLBOX_INCLUDE=$(RLBOX_ROOT)/build/_deps/rlbox-src/code/include

#Our Wasi-SDK
WASI_SDK_ROOT=$(RLBOX_ROOT)/build/_deps/wasiclang-src

#location of our wasi/wasm runtime
WASM2C_RUNTIME_PATH=$(RLBOX_ROOT)/build/_deps/mod_wasm2c-src/wasm2c
WASI_RUNTIME_FILES=$(addprefix $(WASM2C_RUNTIME_PATH), /wasm-rt-impl.c /wasm-rt-exceptions-impl.c)
WASI_RUNTIME_FILES2=$(addprefix $(RLBOX_ROOT)/src, /wasm2c_rt_mem.c /wasm2c_rt_minwasi.c)

WASI_CLANG=$(WASI_SDK_ROOT)/bin/clang
WASM2C=$(RLBOX_ROOT)/build/_deps/mod_wasm2c-src/bin/wasm2c

#CFLAGS for compiling files to play nice with wasm2c
WASM_CFLAGS=-Wl,--export-all -Wl,--no-entry -Wl,--growable-table -Wl,--stack-first -Wl,-z,stack-size=1048576 -Wl,--import-memory -Wl,--import-table


all: target/wasm32-rlbox/debug/mylib.wasm mylib.wasm.c mylib.wasm.o librlbox_wrapper.dylib bin/librlbox_wrapper.dylib bin/bindings.rs rlbox_from_rust run

clean:
	rm -rf target/wasm32-rlbox/debug/mylib.wasm mylib.wasm.c mylib.wasm.h *.o bin/bindings.rs *.dylib bin/*.dylib
	cargo clean
	rm -rf bin/target/

# Step 1: build our library of functions to WASM
target/wasm32-rlbox/debug/mylib.wasm: src/lib.rs
	cargo build --lib -v -Z build-std=std,panic_abort --target wasm32-rlbox.json

# Step 2: use wasm2c to convert our WASM to a C implementation of WASM we can link with our application
mylib.wasm.c: target/wasm32-rlbox/debug/mylib.wasm
	$(WASM2C) target/wasm32-rlbox/debug/mylib.wasm -o mylib.wasm.c

# Step 3: compiling and linking our functions with RLBox
mylib.wasm.o: mylib.wasm.c mylib.wasm.aux.c
	$(CC) -c $(WASI_RUNTIME_FILES) -c $(WASI_RUNTIME_FILES2) -I$(RLBOX_INCLUDE) -I$(RLBOX_ROOT)/include -I$(WASM2C_RUNTIME_PATH) mylib.wasm.c mylib.wasm.aux.c

# Step 4: linking our RLBox wrapper functions with our library of functions and RLBox into a shared library
librlbox_wrapper.dylib: mylib.wasm.o src/rlbox_wrapper.cpp src/rlbox_wrapper.h src/lib.h
	$(CXX) -std=c++17 -shared -o librlbox_wrapper.dylib src/rlbox_wrapper.cpp -I$(RLBOX_INCLUDE) -I$(RLBOX_ROOT)/include -I$(WASM2C_RUNTIME_PATH) *.o -lpthread

# Step 4b: symbolic link to shared lib
bin/librlbox_wrapper.dylib: librlbox_wrapper.dylib
	rm -f bin/librlbox_wrapper.dylib
	ln -s /Users/allenaby/rlbox_example/rlbox_from_rust/librlbox_wrapper.dylib /Users/allenaby/rlbox_example/rlbox_from_rust/bin/librlbox_wrapper.dylib

# Step 5: use bindgen to generate Rust bindings for our RLBox wrappers
bin/bindings.rs: src/rlbox_wrapper.h
	bindgen src/rlbox_wrapper.h -o bin/bindings.rs

# Step 6: build main while pointing to our shared library
rlbox_from_rust: bin/librlbox_wrapper.dylib bin/bindings.rs
	cd bin && cargo -v build --bin mybin --config 'build.rustflags = ["-L", "./"]' && cd -

# Step 7: run while pointing to shared library
run: rlbox_from_rust
	cd bin && cargo run --bin mybin --config 'build.rustflags = ["-L", "./"]' && cd -