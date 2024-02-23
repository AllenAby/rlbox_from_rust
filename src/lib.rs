#![allow(non_upper_case_globals)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]

#[no_mangle]
pub extern "C" fn hello() -> i32 {
    return 100;
}

#[no_mangle]
pub extern "C" fn sum(a: i32, b:i32) -> i32 {
    let v = vec![a, b];
    let sum = v[0] + v[1];
    return sum;
}