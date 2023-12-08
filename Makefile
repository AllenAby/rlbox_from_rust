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


all: target/wasm32-wasi/debug/rlbox_from_rust.wasm mylib.wasm.c mylib.wasm.o rlbox_wrapper.o librlbox_wrapper.a src/bindings.rs rlbox_from_rust

clean:
	rm -rf target/wasm32-wasi/debug/rlbox_from_rust.wasm mylib.wasm.c mylib.wasm.h librlbox_wrapper.a *.o src/bindings.rs
	cargo clean

# Step 1: build our library of functions to WASM
target/wasm32-wasi/debug/rlbox_from_rust.wasm: src/lib.rs
	cargo build --lib -v --target wasm32-wasi --config 'build.rustflags = ["-C", "linker=$(WASI_CLANG)", "-C", "link-args=$(WASM_CFLAGS)"]'

# Step 2: use wasm2c to convert our WASM to a C implementation of WASM we can link with our application
mylib.wasm.c: target/wasm32-wasi/debug/rlbox_from_rust.wasm
	$(WASM2C) target/wasm32-wasi/debug/rlbox_from_rust.wasm -o mylib.wasm.c

# Step 3: compiling and linking our functions with RLBox
mylib.wasm.o: mylib.wasm.c
	$(CC) -c $(WASI_RUNTIME_FILES) -c $(WASI_RUNTIME_FILES2) -I$(RLBOX_INCLUDE) -I$(RLBOX_ROOT)/include -I$(WASM2C_RUNTIME_PATH) mylib.wasm.c

# Step 4: linking our RLBox wrapper functions with our library of functions and RLBox
rlbox_wrapper.o: mylib.wasm.o src/rlbox_wrapper.cpp src/lib.h
	$(CXX) -std=c++17 -c -o rlbox_wrapper.o src/rlbox_wrapper.cpp -I$(RLBOX_INCLUDE) -I$(RLBOX_ROOT)/include -I$(WASM2C_RUNTIME_PATH)

# Step 5: wrapping all these object files to a static library
librlbox_wrapper.a: rlbox_wrapper.o
	ar rcs librlbox_wrapper.a *.o

# Step 6: use bindgen to generate Rust bindings for our RLBox wrappers
src/bindings.rs: src/rlbox_wrapper.h
	bindgen src/rlbox_wrapper.h -o src/bindings.rs

# Step 7: build main while pointing to our static library
rlbox_from_rust: librlbox_wrapper.a src/bindings.rs
	cargo build --config 'build.rustflags = ["-L", "./", "-l", "static=rlbox_wrapper"]'