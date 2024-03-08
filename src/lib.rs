#![allow(non_upper_case_globals)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]

use linfa::dataset::Dataset;
use linfa::prelude::Fit;
use linfa_linear::LinearRegression;
use ndarray::{Array2, Dim, s};

use std::ffi::{c_char, CStr};

use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize, Debug)]
pub struct Point {
    x: i32,
    y: String,
}

#[no_mangle]
pub extern "C" fn hello() -> f32 {
    return 100 as f32;
}

#[no_mangle]
pub extern "C" fn sum(a: i32, b:i32) -> i32 {
    let v: Vec<i32> = vec![a, b];
    let sum: i32 = v[0] + v[1];
    return sum;
}

#[no_mangle]
pub extern "C" fn train_and_predict(x: *const c_char) -> f32 {
    let serialized: &CStr = unsafe { CStr::from_ptr(x) };
    let input: &str = serialized.to_str().unwrap();
    let grades: Vec<[f32; 2]> = serde_json::from_str(input).unwrap();
    let array: Array2<f32> = Array2::from(grades);
    let (x, y) = (
        array.slice(s![.., 0..1]).to_owned(),
        array.column(1).to_owned(),
    );

    let dataset: Dataset<f32, f32, Dim<[usize; 1]>> =
        Dataset::new(x, y).with_feature_names(vec!["x", "y"]);

    // Train the model.
    let lin_reg = LinearRegression::new();
    let model = lin_reg.fit(&dataset).unwrap();
    let grade = model.params()[0] * 0.0 + model.intercept();
    grade as f32
    // grades[0][0]
    // let point: Point = serde_json::from_str(input).unwrap();
    // point.x
}