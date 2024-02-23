#include "rlbox_wrapper.h"

// ANCHOR: imports
// We're going to use RLBox in a single-threaded environment.
#define RLBOX_USE_EXCEPTIONS
#define RLBOX_ENABLE_DEBUG_ASSERTIONS
#define RLBOX_SINGLE_THREADED_INVOCATIONS


// All calls into the sandbox are resolved statically.
#define RLBOX_USE_STATIC_CALLS() rlbox_wasm2c_sandbox_lookup_symbol
#define RLBOX_WASM2C_MODULE_NAME rlbox__from__rust

#include <stdio.h>
#include <cassert>
#include "./lib.h"
#include "../mylib.wasm.h"
#include "rlbox.hpp"
#include "rlbox_wasm2c_sandbox.hpp"

using namespace std;
using namespace rlbox;

// Define base type for mylib/rust_from_c
RLBOX_DEFINE_BASE_TYPES_FOR(rlbox_from_rust, wasm2c);

int invoke_hello() {
  // Declare and create a new sandbox
  rlbox_sandbox_rlbox_from_rust sandbox;
  sandbox.create_sandbox();

  auto ret = sandbox.template INTERNAL_invoke_with_func_ptr<decltype(hello)>(
        "hello",
        sandbox_lookup_symbol_helper(RLBOX_USE_STATIC_CALLS(), hello)).copy_and_verify([](int ret) { return ret; });

  // destroy sandbox
  sandbox.destroy_sandbox();

  return ret;
}

int invoke_sum(int a, int b) {
  // Declare and create a new sandbox
  rlbox_sandbox_rlbox_from_rust sandbox;
  sandbox.create_sandbox();

  auto ret = sandbox.template INTERNAL_invoke_with_func_ptr<decltype(sum)>(
        "sum",
        sandbox_lookup_symbol_helper(RLBOX_USE_STATIC_CALLS(), sum),
        a, b).copy_and_verify([](int ret) { return ret; });

  // destroy sandbox
  sandbox.destroy_sandbox();

  return ret;
}