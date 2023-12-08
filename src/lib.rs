#![allow(non_upper_case_globals)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]

#[no_mangle]
pub extern "C" fn hello_from_rust() -> i32 {
    return 100;
}