#![allow(non_upper_case_globals)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]

// use linfa::dataset::Dataset;
// use linfa::prelude::*;
// use linfa_linear::LinearRegression;
// use ndarray::prelude::*;

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

#[no_mangle]
pub extern "C" fn train_and_predict() -> f64 {
    0.0
}