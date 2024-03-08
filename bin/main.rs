#[link(name = "rlbox_wrapper", kind = "dylib")]
extern "C" {

}

mod bindings;

use serde::{Serialize, Deserialize};
use std::ffi::{c_char, CString};

#[derive(Serialize, Deserialize, Debug)]
pub struct Point {
    x: i32,
    y: String,
}

fn main() {
    let grades: Vec<[f32; 2]> = vec![[10.0, 14.0]];
    let grades_serialized = serde_json::to_string(&grades).unwrap();
    let grades_c_str = CString::new(grades_serialized).unwrap();
    let grades_param: *const c_char = grades_c_str.as_ptr() as *const c_char;
    let point: Point = Point { x: 1, y: "test".to_string()};
    let point_serialized = serde_json::to_string(&point).unwrap();
    let point_c_str = CString::new(point_serialized).unwrap();
    let point_param: *const c_char = point_c_str.as_ptr() as *const c_char;
    unsafe {
        println!("{:?}", bindings::invoke_hello());
        println!("{:?}", bindings::invoke_sum(2, 3));
        println!("{:?}", bindings::invoke_train_and_predict(grades_param));
    }
}