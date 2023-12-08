mod bindings;

fn main() {
    unsafe {
        println!("{:?}", bindings::invoke_hello());
    }
}