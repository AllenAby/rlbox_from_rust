#include "rlbox_wrapper.h"

// ANCHOR: imports
// We're going to use RLBox in a single-threaded environment.
#define RLBOX_USE_EXCEPTIONS
#define RLBOX_ENABLE_DEBUG_ASSERTIONS
#define RLBOX_SINGLE_THREADED_INVOCATIONS


// All calls into the sandbox are resolved statically.
#define RLBOX_USE_STATIC_CALLS() rlbox_wasm2c_sandbox_lookup_symbol
#define RLBOX_WASM2C_MODULE_NAME mylib

#include <stdio.h>
#include <cassert>
#include "./lib.h"
#include "../mylib.wasm.h"
#include "rlbox.hpp"
#include "rlbox_wasm2c_sandbox.hpp"

using namespace std;
using namespace rlbox;

// Define base type for mylib/rust_from_c
RLBOX_DEFINE_BASE_TYPES_FOR(mylib, wasm2c);

float invoke_hello() {
  // Declare and create a new sandbox
  rlbox_sandbox_mylib sandbox;
  sandbox.create_sandbox();

  auto ret = sandbox.template INTERNAL_invoke_with_func_ptr<decltype(hello)>(
        "hello",
        sandbox_lookup_symbol_helper(RLBOX_USE_STATIC_CALLS(), hello)).copy_and_verify([](float ret) { return ret; });

  // destroy sandbox
  sandbox.destroy_sandbox();

  return ret;
}

int invoke_sum(int a, int b) {
  // Declare and create a new sandbox
  rlbox_sandbox_mylib sandbox;
  sandbox.create_sandbox();

  auto ret = sandbox.template INTERNAL_invoke_with_func_ptr<decltype(sum)>(
        "sum",
        sandbox_lookup_symbol_helper(RLBOX_USE_STATIC_CALLS(), sum),
        a, b).copy_and_verify([](int ret) { return ret; });

  // destroy sandbox
  sandbox.destroy_sandbox();

  return ret;
}

float invoke_train_and_predict(const char* a) {
  // Declare and create a new sandbox
  rlbox_sandbox_mylib sandbox;
  sandbox.create_sandbox();

  // Tainting string stage
  size_t a_size = strlen(a) + 1;
  tainted_mylib<char*> tainted_a = sandbox.malloc_in_sandbox<char>(a_size);
  strncpy(tainted_a.unverified_safe_pointer_because(a_size, "writing to region"), a, a_size);

  auto ret = sandbox.template INTERNAL_invoke_with_func_ptr<decltype(train_and_predict)>(
        "train_and_predict",
        sandbox_lookup_symbol_helper(RLBOX_USE_STATIC_CALLS(), train_and_predict),
        tainted_a).copy_and_verify([](float ret) { 
          return ret; 
        });

  // destroy sandbox
  sandbox.destroy_sandbox();

  return ret;
}