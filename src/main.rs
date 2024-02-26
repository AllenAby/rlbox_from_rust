mod bindings;

fn main() {
    let _grades: Vec<[f64; 2]> = vec![[0.0, 0.0]];
    unsafe {
        println!("{:?}", bindings::invoke_hello());
        println!("{:?}", bindings::invoke_sum(2, 3));
        println!("{:?}", bindings::invoke_train_and_predict());
    }
}